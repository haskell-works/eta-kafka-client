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

import Control.Monad.IO.Class
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
newConsumer :: MonadIO m => ConsumerProperties -> m KafkaConsumer
newConsumer props =
  let bsProps = fixedProps <> props
      cons = mkRawConsumer (mkConsumerProps bsProps)
   in liftIO $ KafkaConsumer <$> cons

-- | Subscribes an existing kafka consumer to the specified topics
subscribeTo :: MonadIO m => KafkaConsumer -> [TopicName] -> m ()
subscribeTo (KafkaConsumer kc) ts =
  let rawTopics = toJava $ (\(TopicName t) -> (toJString t)) <$> ts :: J.List JString
   in liftIO $ rawSubscribe kc rawTopics

poll :: MonadIO m => KafkaConsumer -> Millis -> m [ConsumerRecord (Maybe JByteArray) (Maybe JByteArray)]
poll (KafkaConsumer kc) (Millis t) = liftIO $ do
  res <- listRecords <$> rawPoll kc t
  return $ mkConsumerRecord <$> res

commitSync :: MonadIO m => KafkaConsumer -> m ()
commitSync (KafkaConsumer kc) = liftIO $ rawCommitSync kc

commitAsync :: MonadIO m => KafkaConsumer -> m ()
commitAsync (KafkaConsumer kc) = liftIO $ rawCommitAsync kc

unsubscribe :: MonadIO m => KafkaConsumer -> m ()
unsubscribe (KafkaConsumer kc) = liftIO $ rawUnsubscribe kc

closeConsumer :: MonadIO m => KafkaConsumer -> m ()
closeConsumer (KafkaConsumer kc) = liftIO $ rawCloseConsumer kc

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
