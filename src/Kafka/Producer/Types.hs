module Kafka.Producer.Types
where

--
import Data.ByteString
import Kafka.Types

data ProducerRecord = ProducerRecord
  { prTopic     :: !TopicName
  , prPartition :: Maybe PartitionId
  , prKey       :: Maybe ByteString
  , prValue     :: Maybe ByteString
  } deriving (Eq, Show)
