{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module Kafka.Consumer.Types
where

import Java
import Data.Map (Map)
import Data.Bifunctor

--
newtype TopicName   = TopicName JString deriving (Show, Eq, Ord)
newtype PartitionId = PartitionId Int deriving (Show, Eq, Ord, Num)
newtype Offset      = Offset Int64 deriving (Show, Eq, Ord, Num)
newtype Checksum    = Checksum Int64 deriving (Show, Eq, Ord, Num)
newtype Timeout     = Timeout Int64 deriving (Show, Eq, Ord, Num)

data ConsumerRecord k v =
  ConsumerRecord {
    crTopic     :: TopicName,
    crPartition :: PartitionId,
    crOffset    :: Offset,
    crChecksum  :: Checksum,
    crKey       :: k,
    crValue     :: v
  } deriving (Show)

instance Bifunctor ConsumerRecord where
  bimap f g (ConsumerRecord t p o c k v) =  ConsumerRecord t p o c (f k) (g v)

instance Functor (ConsumerRecord k) where
  fmap = second

crMapKey :: (k -> k') -> ConsumerRecord k v -> ConsumerRecord k' v
crMapKey = first

crMapValue :: (v -> v') -> ConsumerRecord k v -> ConsumerRecord k v'
crMapValue = second

crMapKV :: (k -> k') -> (v -> v') -> ConsumerRecord k v -> ConsumerRecord k' v'
crMapKV = bimap
