module Kafka.Types
where

import Java
import Data.Map (Map)

--
newtype TopicName = TopicName JString deriving (Show, Eq, Ord)
