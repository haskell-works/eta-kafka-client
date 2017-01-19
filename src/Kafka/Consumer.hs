module Kafka.Consumer
(
  newConsumer
)where

--
import Java
import Control.Monad(forM_)
import Data.Map (Map)
import qualified Data.Map as M
import Kafka.Internal.Bindings
import Kafka.Internal.Collections

-- convert to Map String String? Or Map Text Text?
newConsumer :: Map JString JString -> Java a (KafkaConsumer k v)
newConsumer props = mkRawConsumer (toJMap props)
