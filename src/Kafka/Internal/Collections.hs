{-# LANGUAGE MagicHash, FlexibleContexts, DataKinds, TypeFamilies #-}
module Kafka.Internal.Collections
( JMap(..), Collection(..), ArrayList(..)
, toJMap
, toJList
) where

import Java
import qualified Java.Array as JA
import Control.Monad(forM_)
import Data.Map (Map)
import qualified Data.Map as M

data {-# CLASS "java.util.Collection" #-} Collection a =
  Collection (Object# (Collection a))
  deriving Class

data {-# CLASS "java.util.List" #-} JList a = JList (Object# (JList a))
  deriving Class

type instance Inherits (JList a) = '[Collection a]

data {-# CLASS "java.util.ArrayList" #-} ArrayList a = ArrayList (Object# (ArrayList a))
  deriving Class

type instance Inherits (ArrayList a) = '[JList a]

foreign import java unsafe "@new" newArrayList :: Java c (ArrayList a)
foreign import java unsafe "add" jalAdd ::
  (Extends a Object, Extends b (Collection a)) => a -> Java b Bool

toJList :: Class a => [a] -> ArrayList a
toJList as = pureJava $ do
  al <- newArrayList
  forM_ as (\x -> al <.> jalAdd x)
  return (al)

-- MAP
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
  forM_ (M.assocs m) (\(k, v) -> hm <.> jmapPut k v)
  return (superCast hm)
