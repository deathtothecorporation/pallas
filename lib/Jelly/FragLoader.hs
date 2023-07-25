-- Copyright 2023 The Plunder Authors
-- Use of this source code is governed by a BSD-style license that can be
-- found in the LICENSE file.

{-# OPTIONS_GHC -Wall -Wno-ambiguous-fields #-}

module Jelly.FragLoader
    ( loadFrags
    , FragSt(..)
    , FragErr(..)
    )
where

import PlunderPrelude hiding ((^), countTrailingZeros)

import Control.Monad.Trans.State.Strict
import Data.Bits
import Fan.Eval
import Foreign.Ptr
import Foreign.Storable

import qualified Data.ByteString     as BS
import qualified Data.Set            as S
import qualified Data.Vector         as V
import qualified Data.Vector.Mutable as VM

import Data.Vector         ((!))
import Data.Vector.Mutable (IOVector)


--------------------------------------------------------------------------------

data FragSt = FRAG_ST
    { used :: !Int
    , word :: !Word64
    , more :: !(Ptr Word64)
    , noGo :: !(Ptr Word64)
    }

data FragErr
    = JELLY_EMPTY_FILE
    | JELLY_BAD_OFFSET Int
    | JELLY_OVERSATURATED_LAW
    | JELLY_BAD_LAW_LITERAL
    | JELLY_NOT_NORMAL Fan [Fan]
  deriving (Eq, Ord, Show, Exception)


--------------------------------------------------------------------------------

loadFrags :: Vector Fan -> Int -> ByteString -> Int -> IO Fan
loadFrags = top
  where
    go tab numPrior elemWid moreFrags = do
        when (moreFrags > 0) do
            val <- loadFan 1 tab numPrior elemWid
            VM.unsafeWrite tab numPrior val
            let numPrior' = numPrior + 1
            let sizeGrows = popCount numPrior == 1
            let elemWid' = if sizeGrows then elemWid+1 else elemWid
            go tab numPrior' elemWid' (moreFrags - 1)

    top leaves nFrag buffer usedBytes = do
        BS.useAsCString buffer \bsPtr -> do
            let nLeaf      = length leaves
            let sz         = nFrag + nLeaf
            let wOff       = usedBytes `div` 8
            let used       = 8 * (usedBytes `mod` 8) -- bits
            let here       = castPtr bsPtr `plusPtr` (wOff * 8)
            let more       = here `plusPtr` 8
            let noGo       = castPtr bsPtr `plusPtr` length buffer
            let maxElemIdx = nLeaf - 1
            let fstElemWid = 64 - countLeadingZeros maxElemIdx
            let fstIdx     = nLeaf

            tab  <- VM.generate sz \i -> if i >= nLeaf then 0 else leaves!i
            word <- peek here

            when (sz == 0) do throwIO JELLY_EMPTY_FILE

            evalStateT (go tab fstIdx fstElemWid nFrag)
                       (FRAG_ST{used,word,more,noGo})

            VM.unsafeRead tab (sz - 1)


--------------------------------------------------------------------------------

-- This assumes that we never advance more than 64 bits.
{-# INLINE advance #-}
advance :: Int -> StateT FragSt IO ()
advance n = do
    st <- get
    let !oldUsed = st.used
    let !newUsed = oldUsed + n
    if newUsed < 64 then do
        put $! st { used = newUsed }
    else do
        next <- if st.more >= st.noGo
                then pure 0
                else liftIO (peek st.more)

        put $! st { used = newUsed `mod` 64
                  , word = next
                  , more = st.more `plusPtr` 8
                  }


--------------------------------------------------------------------------------

-- Consumes /1*0/ and returns the number of ones consumed.
getOnes :: Int -> StateT FragSt IO Int
getOnes !acc = do
    st <- get

    let !used   = st.used
    let !remain = 64 - used
    let !nOnes  = countTrailingZeros $ complement $ shiftR st.word used

    if (nOnes < remain) then do

        -- Can't just bump .used, because the zero consumed may be
        -- the final bit of the word

        advance (nOnes + 1)
        -- showState "after ones (simple)"
        pure (nOnes + acc)

    else do

        -- Slightly faster than `advance` because we are always consuming
        -- just the rest of the word.

        nextWord <-
            if st.more >= st.noGo
            then pure 0
            else liftIO (peek st.more)

        put $! st { used = 0
                  , word = nextWord
                  , more = st.more `plusPtr` 8
                  }

        -- showState "after ones (complex)"

        getOnes (acc + nOnes)


--------------------------------------------------------------------------------

-- Every fragment is always a pair, so we save a bit per fragment by
-- having an implicit `1` at the beginning.

loadFan :: Int -> IOVector Fan -> Int -> Int -> StateT FragSt IO Fan
loadFan implicitOnes refs numElems elemWidth = do
    n <- getOnes implicitOnes
    i <- fromIntegral <$> getBits elemWidth
    f <- if i >= numElems
         then throwIO (JELLY_BAD_OFFSET i)
         else VM.unsafeRead refs (fromIntegral i)
    res <- if (n == 0) then pure f else do
               args <- V.replicateM n (loadFan 0 refs numElems elemWidth)
               construct f args
    pure res


--------------------------------------------------------------------------------

-- @getBits@ (safely) assumes that we never get more than 64 bits.

{-# INLINE getBits #-}
getBits :: Int -> StateT FragSt IO Word64
getBits n = do
    st <- get
    let !oldUsed = st.used
    let !newUsed = oldUsed + n
    case compare newUsed 64 of
        LT -> do
            put $! st { used = newUsed }
            let remain = 64 - newUsed
            let result = shiftR (shiftL st.word remain) (64 - n)
            pure $! result
            -- xxxAAAxx
            -- AAAxx000
            -- 00000AAA

        EQ -> do
            next <- if st.more >= st.noGo
                    then pure 0
                    else liftIO (peek st.more)

            put $! st { used = 0
                      , word = next
                      , more = st.more `plusPtr` 8
                      }

            pure $! shiftR st.word oldUsed
            -- AAxxxxxx
            -- 000000AA

        GT -> do
            next <- if st.more >= st.noGo
                    then pure 0
                    else liftIO (peek st.more)

            let !steal = newUsed `mod` 64

            put $! st { used = steal
                      , word = next
                      , more = st.more `plusPtr` 8
                      }

            let keep     = 64 - oldUsed
            let remain   = 64 - steal
            let highBits = shiftR st.word oldUsed
            let lowBits  = shiftR (shiftL next remain) (remain - keep)
            let result   = highBits .|. lowBits

            pure $! result
            -- Axxxxxxx || cccccBBB
            -- 0000000A || BBB00000
            --          || 0000BBB0
            --       0000BBBA


-- Rebuild Nouns with using %% -------------------------------------------------

-- This is just a fancy version of (foldl' (%%) hed arg) except that it
-- checks to makes sure that no evaluation happens.

construct :: Fan -> Vector Fan -> StateT FragSt IO Fan
construct hed arg = do
    let width    = length arg
    let hedArity = evalArity hed
    let resArity = hedArity - width

    when (width == 0) do
       error "Don't call construct with empty arg list."

    case hed of
       -- The head can be a closure if the head "leaf" is a
       -- back-reference to a fragment that occured more than once.
       KLO _ xs -> do
           let realHed = (xs ^ 0)
           let hedArgs = fromList $ drop 1 $ toList xs
           construct realHed (hedArgs <> arg)

       -- If the result is in WHNF, then no evaluation can happen.
       -- It's safe to just directly construct a KLO node.
       _ | resArity > 0 ->
           pure $ KLO resArity $ smallArrayFromList $ (hed : toList arg)

       NAT 0 ->
           case (arg!0, arg!1, arg!2) of
               (NAT n, NAT a, b) -> constructLaw n a b (drop 3 arg)
               _                 -> lift $ throwIO JELLY_BAD_LAW_LITERAL

       COw{} -> hydrateLaw hed arg
       CAB{} -> hydrateLaw hed arg
       _     -> lift $ throwIO (JELLY_NOT_NORMAL hed $ toList arg)

constructLaw :: Nat -> Nat -> Fan -> Vector Fan -> StateT FragSt IO Fan
constructLaw n a b args = do
    let law = mkLawPreNormalized (LN n) a b
    hydrateLaw law args

hydrateLaw :: Fan -> Vector Fan -> StateT FragSt IO Fan
hydrateLaw law args = do
    let numArgs = length args
    let arity   = evalArity law - numArgs
    let klo     = KLO arity $ smallArrayFromList (law : toList args)

    case law of

        _ | numArgs == 0 -> pure law
        _ | arity > 0    -> pure klo
        _ | arity < 0    -> lift $ throwIO JELLY_OVERSATURATED_LAW

        -- Here we know that the evalArity of the result is 0.
        -- Either this is an actually-saturated form (no good),
        -- or it's a row/tab literal.

        COw{} ->
            pure $ ROW $ reverse args

        CAB ks ->
            case toList args of
                [ROW vs] | length ks == length vs ->
                    pure $ TAb $ mapFromList $ zip (S.toList ks) (toList vs)
                [arg] ->
                    pure (law %% arg) -- malformed cab, just use eval path
                _ ->
                    throwIO $ JELLY_OVERSATURATED_LAW

        _ ->
            lift (throwIO JELLY_OVERSATURATED_LAW)