{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module Kafka.Types
where

import Java

newtype TopicName   = TopicName JString deriving (Show, Eq, Ord)
newtype PartitionId = PartitionId Int deriving (Show, Eq, Ord, Num)
newtype Timestamp   = Timestamp Int64 deriving (Show, Eq, Ord)
