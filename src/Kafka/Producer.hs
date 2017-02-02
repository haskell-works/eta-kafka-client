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
import Java.Collections as J

import Data.Bifunctor
import Data.Map (Map)
import qualified Data.Map as M
import Data.Monoid

import Kafka.Producer.Bindings

import Kafka.Types as X
import Kafka.Producer.Types as X
import Kafka.Producer.ProducerProperties as X

newtype KafkaProducer = KafkaProducer (JKafkaProducer JByteArray JByteArray)

fixedProps :: ProducerProperties
fixedProps = producerProps $ M.fromList
  [ ("key.serializer", "org.apache.kafka.common.serialization.ByteArraySerializer")
  , ("value.serializer", "org.apache.kafka.common.serialization.ByteArraySerializer")
  ]

newProducer :: ProducerProperties -> IO KafkaProducer
newProducer props =
  let bsProps = fixedProps <> props
   in KafkaProducer <$> mkRawProducer (mkProducerProps bsProps)

send :: KafkaProducer -> ProducerRecord JByteArray JByteArray -> IO (JFuture JRecordMetadata)
send (KafkaProducer kp) r = rawSend kp (mkJProducerRecord r)

mkJProducerRecord :: (Class k, Class v) => ProducerRecord k v -> JProducerRecord k v
mkJProducerRecord (ProducerRecord t p k v) =
  let TopicName t' = t
      p' = (\(PartitionId x) -> x) <$> p
   in newJProducerRecord (toJString t') (toJava <$> p') Nothing k v

closeProducer :: KafkaProducer -> IO ()
closeProducer (KafkaProducer kp) = flushProducer kp >> destroyProducer kp

mkProducerProps :: ProducerProperties -> J.Map JString JString
mkProducerProps (ProducerProperties m) =
  toJava $ bimap toJString toJString <$> M.toList m
