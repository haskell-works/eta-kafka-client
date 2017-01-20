{-# LANGUAGE MagicHash, FlexibleContexts, DataKinds, TypeFamilies #-}
module Kafka.Internal.Bindings
where

import Java
import Control.Monad(forM_)
import Data.Map (Map)
import qualified Data.Map as M

import Kafka.Internal.Collections

-- TopicPartition
data {-# CLASS "org.apache.kafka.common.TopicPartition" #-} JTopicPartition =
  JTopicPartition (Object# JTopicPartition)
  deriving Class

foreign import java unsafe "@new" newTopicPartition :: JString -> Int -> JTopicPartition

foreign import java unsafe "topic" tpTopic :: JTopicPartition -> JString

foreign import java unsafe "partition" tpPartition :: JTopicPartition -> Int

-- Consumer
data {-# CLASS "org.apache.kafka.clients.consumer.KafkaConsumer" #-} KafkaConsumer k v =
  KafkaConsumer (Object# (KafkaConsumer k v))
  deriving Class

foreign import java unsafe "@new" mkRawConsumer :: JMap JString JString -> Java a (KafkaConsumer k v)

foreign import java unsafe "close" closeConsumer :: Java (KafkaConsumer k v) ()

foreign import java unsafe "subscribe" rawSubscribe :: JStringArray -> Java (KafkaConsumer k v) ()

foreign import java unsafe "unsubscribe" unsubscribe :: Java (KafkaConsumer k v) ()

foreign import java unsafe "commitSync" commitSync :: Java (KafkaConsumer k v) ()

foreign import java unsafe "commitAsync" commitAsync :: Java (KafkaConsumer k v) ()
