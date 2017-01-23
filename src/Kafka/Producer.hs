{-# LANGUAGE OverloadedStrings #-}
module Kafka.Producer
( module Kafka.Types
, module Kafka.Producer.ProducerProperties
, module Kafka.Producer.Types
, newProducer
, send
, closeProducer
, mkJProducerRecord
) where

import Data.Bifunctor
import Data.Map (Map)
import Data.Monoid
import Java
import Java.Collections
import Kafka.Types
import Kafka.Producer.Bindings
import Kafka.Producer.Types
import Kafka.Producer.ProducerProperties
import qualified Data.Map as M
import Kafka.Internal.Collections

fixedProps :: ProducerProperties
fixedProps = producerProps $ M.fromList
  [ ("key.serializer", "org.apache.kafka.common.serialization.ByteArraySerializer")
  , ("value.serializer", "org.apache.kafka.common.serialization.ByteArraySerializer")
  ]

newProducer :: ProducerProperties -> Java a (KafkaProducer JByteArray JByteArray)
newProducer props =
  let bsProps = fixedProps <> props
   in mkRawProducer (mkProducerProps bsProps)

send :: ProducerRecord JByteArray JByteArray -> Java (KafkaProducer JByteArray JByteArray) (JFuture RecordMetadata)
send = rawSend . mkJProducerRecord

mkJProducerRecord :: (Class k, Class v) => ProducerRecord k v -> JProducerRecord k v
mkJProducerRecord (ProducerRecord t p k v) =
  let TopicName t' = t
      p' = (\(PartitionId x) -> x) <$> p
   in newJProducerRecord (toJString t') (intToJInteger <$> p') Nothing k v

closeProducer :: Java (KafkaProducer k v) ()
closeProducer = flushProducer >> destroyProducer

mkProducerProps :: ProducerProperties -> JMap JString JString
mkProducerProps (ProducerProperties m) =
  toJMap . M.fromList $ bimap toJString toJString <$> M.toList m
