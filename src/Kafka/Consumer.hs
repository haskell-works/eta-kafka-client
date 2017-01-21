{-# LANGUAGE OverloadedStrings #-}
module Kafka.Consumer
( module Kafka.Consumer.Types
, newBytesConsumer
, closeConsumer
, subscribeTo
, commitSync, commitAsync
, poll
) where

--
import Control.Monad(forM_)
import Data.Map (Map)
import Java
import Java.Collections
import Kafka.Consumer.Bindings
import Kafka.Consumer.Types
import Kafka.Internal.Collections
import qualified Data.Map as M
import qualified Java.Array as JA

fixedProps :: Map JString JString
fixedProps = M.fromList
  [ ("key.deserializer", "org.apache.kafka.common.serialization.ByteArrayDeserializer")
  , ("value.deserializer", "org.apache.kafka.common.serialization.ByteArrayDeserializer")
  ]

-- convert to Map String String? Or Map Text Text?
newBytesConsumer :: Map JString JString -> Java a (KafkaConsumer JByteArray JByteArray)
newBytesConsumer props =
  let bsProps = M.union fixedProps props
   in mkRawConsumer (toJMap bsProps)

subscribeTo :: [TopicName] -> Java (KafkaConsumer JByteArray JByteArray) ()
subscribeTo ts =
  let rawTopics = toJList $ (\(TopicName t) -> t) <$> ts
   in rawSubscribe rawTopics

--poll :: Timeout -> Java (KafkaConsumer JByteArray JByteArray) [JConsumerRecord JByteArray JByteArray]
poll :: Timeout -> Java (KafkaConsumer JByteArray JByteArray) [ConsumerRecord (Maybe JByteArray) (Maybe JByteArray)]
poll (Timeout t) = do
  res <- consume <$> (rawPoll t >- iterator)
  return $ mkConsumerRecord <$> res

mkConsumerRecord :: JConsumerRecord JByteArray JByteArray -> ConsumerRecord (Maybe JByteArray) (Maybe JByteArray)
mkConsumerRecord jcr =
  ConsumerRecord
  { crTopic     = TopicName (crTopic' jcr)
  , crPartition = PartitionId (crPartition' jcr)
  , crOffset    = Offset (crOffset' jcr)
  , crChecksum  = Checksum (crChecksum' jcr)
  , crKey       = crKey' jcr
  , crValue     = crValue' jcr
  }
