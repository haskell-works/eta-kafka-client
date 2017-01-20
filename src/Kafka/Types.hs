module Kafka.Types
where

import Java
import Data.Map (Map)

--
newtype TopicName = TopicName JString deriving (Show, Eq, Ord)
newtype Timeout = Timeout Int64 deriving (Show, Eq, Ord)
