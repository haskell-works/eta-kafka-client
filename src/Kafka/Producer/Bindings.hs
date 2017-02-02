{-# LANGUAGE MagicHash, FlexibleContexts, DataKinds, TypeFamilies #-}
module Kafka.Producer.Bindings
where

import Java
import Java.Collections as J
import Control.Monad(forM_)
import Data.Map (Map)
import qualified Data.Map as M

data {-# CLASS "java.util.concurrent.Future" #-} JFuture a = JFuture (Object# (JFuture a))
  deriving (Class)

data {-# CLASS "org.apache.kafka.clients.producer.RecordMetadata" #-} JRecordMetadata = JRecordMetadata (Object# JRecordMetadata)
  deriving (Class)

foreign import java unsafe "offset" rmOffset :: JRecordMetadata -> Int64
foreign import java unsafe "topic" rmTopic :: JRecordMetadata -> JString
foreign import java unsafe "partition" rmPartition :: JRecordMetadata -> Int

-- JProducerRecord
data {-# CLASS "org.apache.kafka.clients.producer.ProducerRecord" #-} JProducerRecord k v =
  JProducerRecord (Object# (JProducerRecord k v))
  deriving (Class, Show)

foreign import java unsafe "@new" newJProducerRecord ::
 (Extends k Object, Extends v Object) => JString -> Maybe JInteger -> Maybe JLong -> Maybe k -> Maybe v -> JProducerRecord k v

-- Producer
data {-# CLASS "org.apache.kafka.clients.producer.KafkaProducer" #-} JKafkaProducer k v =
  JKafkaProducer (Object# (JKafkaProducer k v))
  deriving Class

foreign import java unsafe "@new" mkRawProducer :: J.Map JString JString -> IO (JKafkaProducer k v)
foreign import java unsafe "close" destroyProducer :: JKafkaProducer k v -> IO ()
foreign import java unsafe "flush" flushProducer :: JKafkaProducer k v -> IO ()
foreign import java unsafe "send" rawSend :: JKafkaProducer k v -> JProducerRecord k v -> IO (JFuture JRecordMetadata)
