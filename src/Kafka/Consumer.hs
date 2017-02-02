{-# LANGUAGE OverloadedStrings #-}
module Kafka.Consumer
( module X
, KafkaConsumer
, newConsumer
, closeConsumer
, subscribeTo, unsubscribe
, commitSync, commitAsync
, poll
) where

--
import Java
import Java.Collections as J

import Control.Monad(forM_)
import Data.Bifunctor
import Data.Map (Map)
import qualified Data.Map as M
import Data.Monoid
import Data.String

import Kafka.Consumer.Bindings

import Kafka.Types as X
import Kafka.Consumer.Types as X
import Kafka.Consumer.ConsumerProperties as X

newtype KafkaConsumer = KafkaConsumer (JKafkaConsumer JByteArray JByteArray)

fixedProps :: ConsumerProperties
fixedProps = consumerProps $ M.fromList
  [ ("key.deserializer", "org.apache.kafka.common.serialization.ByteArrayDeserializer")
  , ("value.deserializer", "org.apache.kafka.common.serialization.ByteArrayDeserializer")
  ]

-- | Creates a new Kafka consumer
newConsumer :: ConsumerProperties -> IO KafkaConsumer
newConsumer props =
  let bsProps = fixedProps <> props
   in KafkaConsumer <$> mkRawConsumer (mkConsumerProps bsProps)

-- | Subscribes an existing kafka consumer to the specified topics
subscribeTo :: KafkaConsumer -> [TopicName] -> IO ()
subscribeTo (KafkaConsumer kc) ts =
  let rawTopics = toJava $ (\(TopicName t) -> (toJString t)) <$> ts :: J.List JString
   in rawSubscribe kc rawTopics

poll :: KafkaConsumer -> Timeout -> IO [ConsumerRecord (Maybe JByteArray) (Maybe JByteArray)]
poll (KafkaConsumer kc) (Timeout t) = do
  res <- listRecords <$> rawPoll kc t
  return $ mkConsumerRecord <$> res

commitSync :: KafkaConsumer -> IO ()
commitSync (KafkaConsumer kc) = rawCommitSync kc

commitAsync :: KafkaConsumer -> IO ()
commitAsync (KafkaConsumer kc) = rawCommitAsync kc

unsubscribe :: KafkaConsumer -> IO ()
unsubscribe (KafkaConsumer kc) = rawUnsubscribe kc

closeConsumer :: KafkaConsumer -> IO ()
closeConsumer (KafkaConsumer kc) = rawCloseConsumer kc

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

mkConsumerProps :: ConsumerProperties -> J.Map JString JString
mkConsumerProps (ConsumerProperties m) =
  toJava $ bimap toJString toJString <$> M.toList m
