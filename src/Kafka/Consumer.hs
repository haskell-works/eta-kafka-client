{-# LANGUAGE OverloadedStrings #-}
module Kafka.Consumer
( module X
, KafkaConsumer
, newConsumer
, closeConsumer
, subscribeTo
, commitSync, commitAsync
, poll
) where

--
import Java
import Java.Collections

import Control.Monad(forM_)
import Data.Bifunctor
import Data.Map (Map)
import qualified Data.Map as M
import Data.Monoid
import Data.String

import Kafka.Consumer.Bindings
import Kafka.Internal.Collections

import Kafka.Types as X
import Kafka.Consumer.Types as X
import Kafka.Consumer.ConsumerProperties as X


fixedProps :: ConsumerProperties
fixedProps = consumerProps $ M.fromList
  [ ("key.deserializer", "org.apache.kafka.common.serialization.ByteArrayDeserializer")
  , ("value.deserializer", "org.apache.kafka.common.serialization.ByteArrayDeserializer")
  ]

-- convert to Map String String? Or Map Text Text?
newConsumer :: ConsumerProperties -> Java a (KafkaConsumer JByteArray JByteArray)
newConsumer props =
  let bsProps = fixedProps <> props
   in mkRawConsumer (mkConsumerProps bsProps)

subscribeTo :: [TopicName] -> Java (KafkaConsumer JByteArray JByteArray) ()
subscribeTo ts =
  let rawTopics = toJList $ (\(TopicName t) -> (toJString t)) <$> ts
   in rawSubscribe rawTopics

--poll :: Timeout -> Java (KafkaConsumer JByteArray JByteArray) [JConsumerRecord JByteArray JByteArray]
poll :: Timeout -> Java (KafkaConsumer JByteArray JByteArray) [ConsumerRecord (Maybe JByteArray) (Maybe JByteArray)]
poll (Timeout t) = do
  res <- consume <$> (rawPoll t >- iterator)
  return $ mkConsumerRecord <$> res

mkConsumerRecord :: JConsumerRecord JByteArray JByteArray -> ConsumerRecord (Maybe JByteArray) (Maybe JByteArray)
mkConsumerRecord jcr =
  ConsumerRecord
  { crTopic     = TopicName . fromJString $ crTopic' jcr
  , crPartition = PartitionId (crPartition' jcr)
  , crOffset    = Offset (crOffset' jcr)
  , crChecksum  = Checksum (crChecksum' jcr)
  , crKey       = crKey' jcr
  , crValue     = crValue' jcr
  }

mkConsumerProps :: ConsumerProperties -> JMap JString JString
mkConsumerProps (ConsumerProperties m) =
  toJMap . M.fromList $ bimap toJString toJString <$> M.toList m
