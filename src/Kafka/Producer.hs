{-# LANGUAGE OverloadedStrings #-}
module Kafka.Producer
( module X
, KafkaProducer, JFuture, JRecordMetadata
, newProducer
, send
, closeProducer
, mkJProducerRecord
) where

import Java
import qualified Java.Collections as J

import Data.Bifunctor
import Data.Map (Map)
import qualified Data.Map as M
import Data.Monoid

import Kafka.Producer.Bindings

import Kafka.Types as X
import Kafka.Producer.Types as X
import Kafka.Producer.ProducerProperties as X

data KafkaProducer = KafkaProducer (JKafkaProducer JByteArray JByteArray)

fixedProps :: ProducerProperties
fixedProps = producerProps $ M.fromList
  [ ("key.serializer", "org.apache.kafka.common.serialization.ByteArraySerializer")
  , ("value.serializer", "org.apache.kafka.common.serialization.ByteArraySerializer")
  ]

newProducer :: ProducerProperties -> IO KafkaProducer
newProducer props =
  let bsProps = fixedProps <> props
   in java $ KafkaProducer <$> mkRawProducer (mkProducerProps bsProps)

send :: KafkaProducer -> ProducerRecord JByteArray JByteArray -> IO (JFuture JRecordMetadata)
send (KafkaProducer kp) msg = java $ kp <.> rawSend (mkJProducerRecord msg)

mkJProducerRecord :: (Class k, Class v) => ProducerRecord k v -> JProducerRecord k v
mkJProducerRecord (ProducerRecord t p k v) =
  let TopicName t' = t
      p' = (\(PartitionId x) -> x) <$> p
   in newJProducerRecord (toJString t') (toJava <$> p') Nothing k v

flushProducer :: KafkaProducer -> IO ()
flushProducer (KafkaProducer kp) = java $ kp <.> rawflushProducer

closeProducer :: KafkaProducer -> IO ()
closeProducer p@(KafkaProducer kp) = flushProducer p >> java (kp <.> destroyProducer)

mkProducerProps :: ProducerProperties -> Properties
mkProducerProps (ProducerProperties m) = toJava $ M.toList m
