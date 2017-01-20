{-# LANGUAGE MagicHash, FlexibleContexts, DataKinds, TypeFamilies #-}
module Kafka.Internal.Bindings
where

import Java
import Java.Collections
import Control.Monad(forM_)
import Data.Map (Map)
import qualified Data.Map as M

import Kafka.Internal.Collections

-- TopicPartition
data {-# CLASS "org.apache.kafka.common.TopicPartition" #-} JTopicPartition =
  JTopicPartition (Object# JTopicPartition)
  deriving (Class, Show)

foreign import java unsafe "@new" newTopicPartition :: JString -> Int -> JTopicPartition
foreign import java unsafe "topic" tpTopic :: JTopicPartition -> JString
foreign import java unsafe "partition" tpPartition :: JTopicPartition -> Int

-- ConsumerRecords

data {-# CLASS "org.apache.kafka.clients.consumer.ConsumerRecords" #-} ConsumerRecords k v =
  ConsumerRecords (Object# (ConsumerRecords k v))
  deriving (Class, Show)

type instance Inherits (ConsumerRecords k v) = '[Iterable (ConsumerRecord k v)]

-- ConsumerRecord
data {-# CLASS "org.apache.kafka.clients.consumer.ConsumerRecord" #-} ConsumerRecord k v =
  ConsumerRecord (Object# (ConsumerRecord k v))
  deriving (Class, Show)

foreign import java unsafe "topic" crTopic :: ConsumerRecord k v -> JString
foreign import java unsafe "partition" crPartition :: ConsumerRecord k v -> Int
foreign import java unsafe "key" crKey :: (Extends k Object) => ConsumerRecord k v -> Maybe k
foreign import java unsafe "value" crValue :: (Extends v Object) => ConsumerRecord k v -> Maybe v
foreign import java unsafe "offset" crOffset :: ConsumerRecord k v -> Int64
foreign import java unsafe "checksum" crChecksum :: ConsumerRecord k v -> Int64

-- Consumer
data {-# CLASS "org.apache.kafka.clients.consumer.KafkaConsumer" #-} KafkaConsumer k v =
  KafkaConsumer (Object# (KafkaConsumer k v))
  deriving Class

foreign import java unsafe "@new" mkRawConsumer :: JMap JString JString -> Java a (KafkaConsumer k v)
foreign import java unsafe "close" closeConsumer :: Java (KafkaConsumer k v) ()
foreign import java unsafe "subscribe" rawSubscribe :: (Extends b (Collection JString)) => b -> Java (KafkaConsumer k v) ()
foreign import java unsafe "unsubscribe" unsubscribe :: Java (KafkaConsumer k v) ()
foreign import java unsafe "commitSync" commitSync :: Java (KafkaConsumer k v) ()
foreign import java unsafe "commitAsync" commitAsync :: Java (KafkaConsumer k v) ()

foreign import java unsafe "poll" rawPoll :: Int64 -> Java (KafkaConsumer k v) (ConsumerRecords k v)
