{-# LANGUAGE MagicHash, FlexibleContexts, DataKinds, TypeFamilies #-}
module Kafka.Internal.Bindings
where

import Java
import Control.Monad(forM_)
import Data.Map (Map)
import qualified Data.Map as M

import Kafka.Internal.Collections

data {-# CLASS "org.apache.kafka.clients.consumer.KafkaConsumer" #-} KafkaConsumer k v =
  KafkaConsumer (Object# (KafkaConsumer k v))
  deriving Class

foreign import java unsafe "@new" mkRawConsumer :: JMap JString JString -> Java a (KafkaConsumer k v)

foreign import java unsafe "close" closeConsumer :: Java (KafkaConsumer k v) ()
