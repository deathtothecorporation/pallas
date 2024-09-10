module Server.Hardware.TCP where

import Data.Acquire
import Data.Bits (toIntegralSized)
import Fan.Convert
import Fan.Eval
import Fan.Prof
import PlunderPrelude
import Server.Hardware.Types
import Server.Common
import Network.Socket hiding (socket)
import qualified Data.ByteString as BS
import Data.IntMap.Strict (IntMap)
import qualified Data.IntMap.Strict as IntMap

data TCPState = TCP_STATE
    { connections  :: TVar (IntMap Connection)
    , nextConnId   :: TVar Int
    , nextHearId   :: TVar Int
    , acceptPool   :: TVar (Pool SysCall)
    , openPool     :: TVar (Pool SysCall)
    , takePool     :: TVar (Pool SysCall)
    , givePool     :: TVar (Pool SysCall)
    }

data Connection = CONNECTION
    { buffer :: TQueue ByteString
    }

createHardwareTCP :: Acquire Device
createHardwareTCP = do
    st <- mkAcquire startup shutdown
    pure DEVICE
        { spin     = const pass
        , stop     = const $ stopTCP st
        , call     = runSysCall st
        , category = categoryCall
        , describe = describeCall
        }
  where
    startup :: IO TCPState
    startup = do
        connections <- newTVarIO mempty
        nextConnId <- newTVarIO 0
        nextHearId <- newTVarIO 0
        acceptPool <- newTVarIO emptyPool
        openPool <- newTVarIO emptyPool
        takePool <- newTVarIO emptyPool
        givePool <- newTVarIO emptyPool
        let st = TCP_STATE {..}
        void $ async $ acceptWorker st
        void $ async $ takeWorker st
        pure st

    shutdown :: TCPState -> IO ()
    shutdown st = pass

stopTCP :: TCPState -> IO ()
stopTCP _ = pass

runSysCall :: TCPState -> SysCall -> STM (Cancel, [Flow])
runSysCall st syscall = case decodeRequest syscall.args of
    Just MINE     -> onMine st syscall
    Just HEAR     -> onHear st syscall
    Just (OPEN ip port) -> onOpen st syscall ip port
    Just (TAKE handle)  -> onTake st syscall handle
    Just (GIVE handle payload) -> onGive st syscall handle payload
    Nothing       -> fillInvalidSyscall syscall $> (CANCEL pass, [])

decodeRequest :: Vector Fan -> Maybe TCPRequest
decodeRequest = toList <&> \case
    [NAT "mine"]                          -> Just MINE
    [NAT "hear"]                          -> Just HEAR
    [NAT "open", NAT ip, NAT port]        -> Just $ OPEN 0 0
    [NAT "take", NAT handle]              -> Just $ TAKE (fromIntegral handle)
    [NAT "give", NAT handle, BAR payload] -> Just $ GIVE (fromIntegral handle) payload
    _                                     -> Nothing

data TCPRequest
    = MINE
    | HEAR
    | OPEN HostAddress PortNumber
    | TAKE Int
    | GIVE Int ByteString

onMine :: TCPState -> SysCall -> STM (Cancel, [Flow])
onMine _ syscall = fillInvalidSyscall syscall $> (CANCEL pass, [])

onHear :: TCPState -> SysCall -> STM (Cancel, [Flow])
onHear st syscall = do
    key <- poolRegister st.acceptPool syscall
    pure (CANCEL (poolUnregister st.acceptPool key), [])

onOpen :: TCPState -> SysCall -> HostAddress -> PortNumber -> STM (Cancel, [Flow])
onOpen st syscall ip port = do
    connId <- readTVar st.nextConnId
    writeTVar st.nextConnId (connId + 1)
    buffer <- newTQueue
    modifyTVar st.connections $ IntMap.insert connId CONNECTION{..}
    flow <- writeResponse syscall (NAT $ fromIntegral connId)
    pure (CANCEL pass, [flow])

onTake :: TCPState -> SysCall -> Int -> STM (Cancel, [Flow])
onTake st syscall handle = do
    mconn <- IntMap.lookup handle <$> readTVar st.connections
    case mconn of
        Nothing -> fillInvalidSyscall syscall $> (CANCEL pass, [])
        Just conn -> tryReadTQueue conn.buffer >>= \case
            Nothing -> do
                key <- poolRegister st.takePool syscall
                pure (CANCEL (poolUnregister st.takePool key), [])
            Just payload -> do
                flow <- writeResponse syscall (BAR payload)
                pure (CANCEL pass, [flow])

onGive :: TCPState -> SysCall -> Int -> ByteString -> STM (Cancel, [Flow])
onGive st syscall handle payload = do
    mconn <- IntMap.lookup handle <$> readTVar st.connections
    case mconn of
        Nothing -> fillInvalidSyscall syscall $> (CANCEL pass, [])
        Just conn -> do
            traverse (writeTQueue conn.buffer) $ go payload
            flow <- writeResponse syscall ()
            pure (CANCEL pass, [flow])
  where
    go bs
      | BS.null bs = []
      | otherwise  = let (chunk, rest) = BS.splitAt 6 bs
                     in chunk : go rest

categoryCall :: Vector Fan -> Text
categoryCall args = "%tcp " <> case decodeRequest args of
    Nothing -> "UNKNOWN"
    Just MINE -> "%mine"
    Just HEAR -> "%hear"
    Just OPEN{} -> "%open"
    Just TAKE{} -> "%take"
    Just GIVE{} -> "%give"

describeCall :: Vector Fan -> Text
describeCall args = "%tcp " <> case decodeRequest args of
    Nothing -> "UNKNOWN"
    Just MINE -> "%mine"
    Just HEAR -> "%hear"
    Just OPEN{} -> "%open" -- TODO args
    Just TAKE{} -> "%take" -- TODO args
    Just GIVE{} -> "%give" -- TODO args

acceptWorker :: TCPState -> IO Void
acceptWorker st = forever do
    atomically do
        (syscall, handle) <- poolTakeNext st.acceptPool $ \syscall ->
          case decodeRequest syscall.args of
            Just HEAR -> do
              handle <- readTVar st.nextHearId
              modifyTVar st.nextHearId (+1)
              IntMap.member handle <$> readTVar st.connections >>= \case
                True -> pure (syscall, handle)
                False -> retry
        void $ writeResponse syscall (NAT $ fromIntegral handle)

takeWorker :: TCPState -> IO Void
takeWorker st = forever $ atomically do
    (syscall, conn) <- poolTakeNext st.takePool $ \syscall ->
        case decodeRequest syscall.args of
            Just (TAKE handle) -> do
                mconn <- IntMap.lookup handle <$> readTVar st.connections
                case mconn of
                    Just conn -> pure (syscall, conn)
                    Nothing   -> retry
            _ -> error "Unexpected syscall in takePool"
    payload <- readTQueue conn.buffer
    void $ writeResponse syscall (BAR payload)
