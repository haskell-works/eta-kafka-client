{-# LANGUAGE MagicHash, FlexibleContexts, DataKinds, TypeFamilies, OverloadedStrings, ScopedTypeVariables #-}
module Main where

import Java
import qualified Java.Array as JA
import Control.Monad(forM_)
import Data.Map (Map)
import qualified Data.Map as M
import Kafka.Consumer
import Kafka.Producer

consumerConf :: Map JString JString
consumerConf = M.fromList
  [ ("bootstrap.servers", "localhost:9092")
  , ("group.id", "test-group-1")
  , ("auto.offset.reset", "earliest")
  , ("enable.auto.commit", "false")
  ]

producerConf :: Map JString JString
producerConf = M.fromList
  [ ("bootstrap.servers", "localhost:9092")
  ]

targetTopic = TopicName "results-0"
fv :: JString
fv = "M.valid"

-- Refactor this to only run java monad once
main :: IO ()
main = do
  cons <- java $ newBytesConsumer consumerConf
  prod <- java $ newProducer producerConf
  _    <- javaWith cons $ subscribeTo [TopicName "attacks"]
  crs  <- javaWith cons $ poll (Timeout 1000)
  forM_ (toProducerRecord <$> crs) (javaWith prod . send)
  print . show $ length crs
  javaWith cons closeConsumer
  javaWith prod closeProducer
  print "Ok."

data RecordMetatada = RecordMetatada TopicName PartitionId Offset Checksum
  deriving (Show)

rmFromRecord :: ConsumerRecord k v -> RecordMetatada
rmFromRecord (ConsumerRecord t p o c _ _) =
  RecordMetatada t p o c

toProducerRecord :: ConsumerRecord (Maybe k) (Maybe v) -> ProducerRecord k v
toProducerRecord cr = ProducerRecord targetTopic (Just $ crPartition cr) (crKey cr) (crValue cr)
