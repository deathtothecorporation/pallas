{-# OPTIONS_GHC -Wall   #-}
{-# OPTIONS_GHC -Werror #-}

{-|
    Types for Sire syntax trees (`Cmd`, `Exp`, etc).  "Sire.Syntax"
    parses `Rex` into concrete syntax trees, and "Sire.ReplExe"
    does... everything else (TODO)
-}
module Sire.Types
    ( Symb
    , Cmd(..)
    , TestEql(..)
    , Fun(..)
    , Exp(..)
    , XCmd
    , XExp
    , XFun
    , Fan
    , Defn(..)
    , Req(..)
    )
where

import PlunderPrelude

import Fan        (Fan, LawName)
import Loot.Types (Symb)
import Rex        (Rex)

---------------
-- Functions --
---------------

type XFun = Fun Symb Symb
type XExp = Exp Symb Symb
type XCmd = Cmd Symb Symb

{-|
    A Sire function has an identifier for self-reference, a `LawName,
    a non-empty list of arguments, and an body expression.

    Note that when a function is bound (say with
    @(`ELET` v (`ELAM` (`FUN` w _ _ _)) _)@), there are two binders
    for the same function (@v@ and @w@).  @v@ is the binder used in the
    outside scope, and @w@ is use for self-references.  The difference
    doesn't matter during parsing, but it matters in code transformations.
-}
data Fun v a
    = FUN v LawName (NonEmpty v) (Exp v a)
 deriving (Eq, Ord, Show, Functor, Foldable, Traversable, Generic, NFData)

{-|
    Sire Expressions.  @v@ is the type of local variables, and @a@
    is the type of free variables.

    The parser just treats all references as free variables.  Later on,
    name resolution splits them apart.
-}
data Exp v a
    = EBED Fan                    -- ^ An embedded plunder value
    | EREF a                      -- ^ A free variable.
    | EVAR v                      -- ^ A bound variable.
    | ENAT Nat                    -- ^ A natural-number literal.
    | EAPP (Exp v a) (Exp v a)    -- ^ Function application
    | ELET v (Exp v a) (Exp v a)  -- ^ Let-binding
    | EREC v (Exp v a) (Exp v a)  -- ^ Self-recursive let binding.
    | ELAM Bool (Fun v a)         -- ^ Nested Function (Closure)
    | ELIN (NonEmpty (Exp v a))   -- ^ Explicit Inline Application
  deriving (Eq, Ord, Show, Functor, Foldable, Traversable, Generic, NFData)

{-
    REQ_BLOCK  :: Set Nat -> IO (Nat, Val, Val)
    REQ_SUBMIT :: Nat -> Any -> IO ()
    REQ_CANCEL :: Nat -> IO ()
    REQ_FETCH  :: IO (Map Nat (Val, Maybe Val))
-}
data Req a
    = REQ_FETCH Symb
    | REQ_CANCEL Symb
    | REQ_SUBMIT (Symb, a)
    | REQ_BLOCK (Symb,Symb,Symb) (Set Symb)
  deriving (Eq, Ord, Show, Functor, Foldable, Traversable, Generic, NFData)

-------------------
-- REPL Commands --
-------------------

data TestEql  v a =
    TEST_EQL [Rex] (Exp v a) (Exp v a)
  deriving (Eq, Ord, Show, Functor, Foldable, Traversable, Generic, NFData)

-- |Sire input commands.
data Cmd v a
    = CMDSEQ [Cmd v a]
        -- ^ @(* = x 3)(* = y 4)@ Multiple commands in block.

    | IMPORT [(Text, Maybe (Set Symb))]
        -- ^ @(/+ foo [x y])@ Import @x@ and @y@ from `sire/foo.sire`

    | FILTER [Symb]
       -- ^ @(^-^ x y)@ Restrict the namespace to just x and y.

    | OUTPUT (Exp v a)
       -- ^ @(e)@ Eval+print @e@

    | DUMPIT (Exp v a)
       -- ^ @(<e)@ Eval+print @e@ and it's environment.

    | ASSERT [TestEql v a]
       -- ^ @!!= e f@ Assert that e==f

    | DEFINE [Defn v a]
       -- ^ @(x=y)@, @((f x)=x)@ Bind a value or function in the global
       --   namespace.

  deriving (Eq, Ord, Show, Functor, Foldable, Traversable, Generic, NFData)

type Doc = Maybe Text

-- |A binder.  It's either a function (takes arguments) or a value
-- (does not).
data Defn v a
    = BIND_FUN !Nat a Doc (Fun v a)
    | BIND_EXP !Nat a Doc (Exp v a)
  deriving (Eq, Ord, Show, Functor, Foldable, Traversable, Generic, NFData)
