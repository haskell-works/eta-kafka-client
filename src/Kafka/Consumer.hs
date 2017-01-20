{-# LANGUAGE OverloadedStrings #-}
module Kafka.Consumer
(
  newBytesConsumer
, closeConsumer
, subscribeTo
, commitSync, commitAsync
)where

--
import Java
import qualified Java.Array as JA
import Control.Monad(forM_)
import Data.Map (Map)
import qualified Data.Map as M
import Kafka.Internal.Bindings
import Kafka.Internal.Collections
import Kafka.Types

fixedProps :: Map JString JString
fixedProps = M.fromList
  [ ("key.deserializer", "org.apache.kafka.common.serialization.ByteArrayDeserializer")
  , ("value.deserializer", "org.apache.kafka.common.serialization.ByteArrayDeserializer")
  ]

-- convert to Map String String? Or Map Text Text?
newBytesConsumer :: Map JString JString -> Java a (KafkaConsumer JBytes JBytes)
newBytesConsumer props =
  let bsProps = M.union props fixedProps
      aaa = newTopicPartition "Asd" 1
   in mkRawConsumer (toJMap bsProps)

subscribeTo :: [TopicName] -> Java (KafkaConsumer k v) ()
subscribeTo ts =
  let rawTopics = JA.fromList $ (\(TopicName t) -> t) <$> ts
   in rawTopics >>= rawSubscribe
