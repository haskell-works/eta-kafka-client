{-# LANGUAGE MagicHash, FlexibleContexts, DataKinds, TypeFamilies #-}
module Kafka.Producer.Bindings
where

import Java
import Java.Collections
import Control.Monad(forM_)
import Data.Map (Map)
import qualified Data.Map as M

import Kafka.Internal.Collections

data {-# CLASS "java.lang.Integer" #-} JInteger = JInteger (Object# JInteger)
data {-# CLASS "java.lang.Long" #-} JLong = JLong (Object# JLong)

foreign import java "@new" intToJInteger :: Int -> JInteger
foreign import java "@new" int64ToJLong :: Int64 -> JLong

data {-# CLASS "java.util.concurrent.Future" #-} JFuture a = JFuture (Object# (JFuture a))
  deriving (Class)

data {-# CLASS "org.apache.kafka.clients.producer.RecordMetadata" #-} RecordMetadata = RecordMetadata (Object# RecordMetadata)
  deriving (Class)

-- JProducerRecord
data {-# CLASS "org.apache.kafka.clients.producer.ProducerRecord" #-} JProducerRecord k v =
  JProducerRecord (Object# (JProducerRecord k v))
  deriving (Class, Show)

foreign import java unsafe "@new" newJProducerRecord ::
 (Extends k Object, Extends v Object) => JString -> Maybe JInteger -> Maybe JLong -> Maybe k -> Maybe v -> JProducerRecord k v

foreign import java unsafe "@new" newJProducerRecord2 ::
  (Extends k Object, Extends v Object) => JString -> JInteger -> JLong -> k -> v -> JProducerRecord k v

-- Producer
data {-# CLASS "org.apache.kafka.clients.producer.KafkaProducer" #-} KafkaProducer k v =
  KafkaProducer (Object# (KafkaProducer k v))
  deriving Class

foreign import java unsafe "@new" mkRawProducer :: JMap JString JString -> Java a (KafkaProducer k v)
foreign import java unsafe "close" destroyProducer :: Java (KafkaProducer k v) ()
foreign import java unsafe "flush" flushProducer :: Java (KafkaProducer k v) ()
foreign import java unsafe "send" rawSend :: JProducerRecord k v -> Java (KafkaProducer k v) (JFuture RecordMetadata)
