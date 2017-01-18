{-# LANGUAGE MagicHash, FlexibleContexts, DataKinds, TypeFamilies #-}
module Kafka.Internal.Collections
( JMap(..)
, toJMap
) where

import Java
import Control.Monad(forM_)
import Data.Map (Map)
import qualified Data.Map as M

data {-# CLASS "java.util.Map" #-} JMap k v = JMap (Object# (JMap k v))
  deriving (Class, Show)

data {-# CLASS "java.util.HashMap" #-} JHashMap k v
  = JHashMap (Object# (JHashMap k v))
  deriving (Class, Show)

type instance Inherits (JHashMap k v) = '[Object, JMap k v]

foreign import java unsafe "@new" newHashMap :: Java a (JHashMap k v)

foreign import java unsafe "put"
  jmapPut :: (Extends k Object, Extends v Object)
          => k -> v -> Java (JHashMap k v) v

toJMap :: (Class k, Class v) => Map k v -> JMap k v
toJMap m = pureJava $ do
  hm <- newHashMap
  forM_ (M.assocs m) $ \(k, v) ->
    hm <.> jmapPut k v
  return (superCast hm)
