{-# LANGUAGE OverloadedStrings #-}
module Kafka.Producer
( module Kafka.Types
, module Kafka.Producer.Types
, newProducer
, send
, closeProducer
, mkJProducerRecord
) where

import Java
import Java.Collections
import Kafka.Types
import Kafka.Producer.Bindings
import Kafka.Producer.Types
import Data.Map (Map)
import qualified Data.Map as M
import Kafka.Internal.Collections

fixedProps :: Map JString JString
fixedProps = M.fromList
  [ ("key.serializer", "org.apache.kafka.common.serialization.ByteArraySerializer")
  , ("value.serializer", "org.apache.kafka.common.serialization.ByteArraySerializer")
  ]

newProducer :: Map JString JString -> Java a (KafkaProducer JByteArray JByteArray)
newProducer props =
  let bsProps = M.union fixedProps props
   in mkRawProducer (toJMap bsProps)

send :: ProducerRecord JByteArray JByteArray -> Java (KafkaProducer JByteArray JByteArray) (JFuture RecordMetadata)
send = rawSend . mkJProducerRecord

mkJProducerRecord :: (Class k, Class v) => ProducerRecord k v -> JProducerRecord k v
mkJProducerRecord (ProducerRecord t p k v) =
  let TopicName t' = t
      p' = (\(PartitionId x) -> x) <$> p
   in newJProducerRecord t' (intToJInteger <$> p') Nothing k v

closeProducer :: Java (KafkaProducer k v) ()
closeProducer = flushProducer >> destroyProducer
