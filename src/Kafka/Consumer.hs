{-# LANGUAGE OverloadedStrings #-}
module Kafka.Consumer
(
  newBytesConsumer
, closeConsumer
)where

--
import Java
import Control.Monad(forM_)
import Data.Map (Map)
import qualified Data.Map as M
import Kafka.Internal.Bindings
import Kafka.Internal.Collections

fixedProps :: Map JString JString
fixedProps = M.fromList
  [ ("key.deserializer", "org.apache.kafka.common.serialization.ByteArrayDeserializer")
  , ("value.deserializer", "org.apache.kafka.common.serialization.ByteArrayDeserializer")
  ]

-- convert to Map String String? Or Map Text Text?
newBytesConsumer :: Map JString JString -> Java a (KafkaConsumer JBytes JBytes)
newBytesConsumer props =
  let bsProps = M.union props fixedProps
   in mkRawConsumer (toJMap bsProps)
