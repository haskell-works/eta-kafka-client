{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module Kafka.Consumer.Types
where

import Java
import Data.Map (Map)
import Data.Bifunctor
import Data.Bifoldable
import Data.Bitraversable
import Kafka.Types
import qualified Data.Map as M
import qualified Data.List as L
import Data.Monoid


--
newtype ConsumerGroupId = ConsumerGroupId String deriving (Show, Eq, Ord)
newtype ClientId    = ClientId String deriving (Show, Eq, Ord)
newtype Offset      = Offset Int64 deriving (Show, Eq, Ord, Num)
newtype Checksum    = Checksum Int64 deriving (Show, Eq, Ord, Num)
newtype Millis      = Millis Int64 deriving (Show, Eq, Ord, Num)
data OffsetReset    = Earliest | Latest deriving (Show, Eq)

data ConsumerRecord k v =
  ConsumerRecord {
    crTopic     :: TopicName,
    crPartition :: PartitionId,
    crOffset    :: Offset,
    crChecksum  :: Checksum,
    crKey       :: k,
    crValue     :: v
  } deriving (Show)

--
instance Bifunctor ConsumerRecord where
  bimap f g (ConsumerRecord t p o c k v) =  ConsumerRecord t p o c (f k) (g v)
  {-# INLINE bimap #-}

instance Functor (ConsumerRecord k) where
  fmap = second
  {-# INLINE fmap #-}

instance Foldable (ConsumerRecord k) where
  foldMap f r = f (crValue r)
  {-# INLINE foldMap #-}

instance Traversable (ConsumerRecord k) where
  traverse f r = (\v -> crMapValue (const v) r) <$> f (crValue r)
  {-# INLINE traverse #-}

instance Bifoldable ConsumerRecord where
  bifoldMap f g r = f (crKey r) `mappend` g (crValue r)
  {-# INLINE bifoldMap #-}

instance Bitraversable ConsumerRecord where
  bitraverse f g r = (\k v -> bimap (const k) (const v) r) <$> f (crKey r) <*> g (crValue r)
  {-# INLINE bitraverse #-}

crMapKey :: (k -> k') -> ConsumerRecord k v -> ConsumerRecord k' v
crMapKey = first
{-# INLINE crMapKey #-}

crMapValue :: (v -> v') -> ConsumerRecord k v -> ConsumerRecord k v'
crMapValue = second
{-# INLINE crMapValue #-}

crMapKV :: (k -> k') -> (v -> v') -> ConsumerRecord k v -> ConsumerRecord k' v'
crMapKV = bimap
{-# INLINE crMapKV #-}

sequenceFirst :: (Bitraversable t, Applicative f) => t (f k) v -> f (t k v)
sequenceFirst = bitraverse id pure
{-# INLINE sequenceFirst #-}

traverseFirst :: (Bitraversable t, Applicative f)
              => (k -> f k')
              -> t k v
              -> f (t k' v)
traverseFirst f = bitraverse f pure
{-# INLINE traverseFirst #-}

traverseFirstM :: (Bitraversable t, Applicative f, Monad m)
               => (k -> m (f k'))
               -> t k v
               -> m (f (t k' v))
traverseFirstM f r = bitraverse id pure <$> bitraverse f pure r
{-# INLINE traverseFirstM #-}

traverseM :: (Traversable t, Applicative f, Monad m)
          => (v -> m (f v'))
          -> t v
          -> m (f (t v'))
traverseM f r = sequenceA <$> traverse f r
{-# INLINE traverseM #-}

bitraverseM :: (Bitraversable t, Applicative f, Monad m)
            => (k -> m (f k'))
            -> (v -> m (f v'))
            -> t k v
            -> m (f (t k' v'))
bitraverseM f g r = bisequenceA <$> bimapM f g r
{-# INLINE bitraverseM #-}
