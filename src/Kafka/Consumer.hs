{-# LANGUAGE OverloadedStrings #-}
module Kafka.Consumer
( Timeout(..), TopicName(..)
, newBytesConsumer
, closeConsumer
, subscribeTo
, commitSync, commitAsync
, ConsumerRecord(..)
, poll
, crTopic
, crPartition
, crKey
, crValue
, crOffset
, crChecksum
)where

--
import Java
import Java.Collections
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
newBytesConsumer :: Map JString JString -> Java a (KafkaConsumer JByteArray JByteArray)
newBytesConsumer props =
  let bsProps = M.union props fixedProps
   in mkRawConsumer (toJMap bsProps)

subscribeTo :: [TopicName] -> Java (KafkaConsumer k v) ()
subscribeTo ts =
  let rawTopics = toJList $ (\(TopicName t) -> t) <$> ts
   in rawSubscribe rawTopics

poll :: Timeout -> Java (KafkaConsumer k v) [ConsumerRecord k v]
poll (Timeout t) = consume <$> (rawPoll t >- iterator)
