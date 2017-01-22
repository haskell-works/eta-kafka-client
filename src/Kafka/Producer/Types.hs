module Kafka.Producer.Types
where

--
import Kafka.Types

data ProducerRecord k v =
  ProducerRecord {
    prTopic     :: TopicName,
    prPartition :: Maybe PartitionId,
    prKey       :: Maybe k,
    prValue     :: Maybe v
  } deriving (Show)
