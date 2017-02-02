{-# LANGUAGE MagicHash, FlexibleContexts, DataKinds, TypeFamilies, ScopedTypeVariables #-}
module Kafka.Consumer.Bindings
where

import Java
import Java.Collections as J
import Control.Monad(forM_)
import Data.Map (Map)
import qualified Data.Map as M

-- TopicPartition
data {-# CLASS "org.apache.kafka.common.TopicPartition" #-} JTopicPartition =
  JTopicPartition (Object# JTopicPartition)
  deriving (Class, Show)

foreign import java unsafe "@new" newTopicPartition :: JString -> Int -> JTopicPartition
foreign import java unsafe "topic" tpTopic :: JTopicPartition -> JString
foreign import java unsafe "partition" tpPartition :: JTopicPartition -> Int

-- JConsumerRecords
data {-# CLASS "org.apache.kafka.clients.consumer.ConsumerRecords" #-} JConsumerRecords k v =
  JConsumerRecords (Object# (JConsumerRecords k v))
  deriving (Class, Show)

type instance Inherits (JConsumerRecords k v) = '[Iterable (JConsumerRecord k v)]

-- JConsumerRecord
data {-# CLASS "org.apache.kafka.clients.consumer.ConsumerRecord" #-} JConsumerRecord k v =
  JConsumerRecord (Object# (JConsumerRecord k v))
  deriving (Class, Show)

foreign import java unsafe "topic" crTopic' :: JConsumerRecord k v -> JString
foreign import java unsafe "partition" crPartition' :: JConsumerRecord k v -> Int
foreign import java unsafe "key" crKey' :: (Extends k Object) => JConsumerRecord k v -> Maybe k
foreign import java unsafe "value" crValue' :: (Extends v Object) => JConsumerRecord k v -> Maybe v
foreign import java unsafe "offset" crOffset' :: JConsumerRecord k v -> Int64
foreign import java unsafe "checksum" crChecksum' :: JConsumerRecord k v -> Int64

-- Consumer
data {-# CLASS "org.apache.kafka.clients.consumer.KafkaConsumer" #-} KafkaConsumer k v =
  KafkaConsumer (Object# (KafkaConsumer k v))
  deriving Class


foreign import java unsafe "@new" mkRawConsumer :: J.Map JString JString -> Java a (KafkaConsumer k v)
foreign import java unsafe "close" closeConsumer :: Java (KafkaConsumer k v) ()
foreign import java unsafe "subscribe" rawSubscribe :: (Extends b (Collection JString)) => b -> Java (KafkaConsumer k v) ()
foreign import java unsafe "unsubscribe" unsubscribe2 :: Java (KafkaConsumer k v) ()
foreign import java unsafe "commitSync" commitSync :: Java (KafkaConsumer k v) ()
foreign import java unsafe "commitAsync" commitAsync :: Java (KafkaConsumer k v) ()

foreign import java unsafe "poll" rawPoll :: Int64 -> Java (KafkaConsumer k v) (JConsumerRecords k v)

listRecords :: forall k v. JConsumerRecords k v -> [JConsumerRecord k v]
listRecords rs = fromJava (superCast rs :: Iterable (JConsumerRecord k v))
