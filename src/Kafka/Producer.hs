{-# LANGUAGE OverloadedStrings #-}
module Kafka.Producer
( module X
, KafkaProducer, JFuture, JRecordMetadata
, newProducer
, send
, closeProducer
, mkJProducerRecord
) where

import           Java
import           Java.Collections                  as J

import           Control.Monad.IO.Class
import           Data.Bifunctor
import           Data.ByteString                   as BS
import           Data.Map                          (Map)
import qualified Data.Map                          as M
import           Data.Monoid

import           Kafka.Producer.Bindings

import           Kafka.Producer.ProducerProperties as X
import           Kafka.Producer.Types              as X
import           Kafka.Types                       as X

newtype KafkaProducer = KafkaProducer (JKafkaProducer JByteArray JByteArray)

fixedProps :: ProducerProperties
fixedProps = extraProducerProps $ M.fromList
  [ ("key.serializer", "org.apache.kafka.common.serialization.ByteArraySerializer")
  , ("value.serializer", "org.apache.kafka.common.serialization.ByteArraySerializer")
  ]

newProducer :: MonadIO m
            => ProducerProperties
            -> m KafkaProducer
newProducer props =
  let bsProps = fixedProps <> props
      prod = mkRawProducer (mkProducerProps bsProps)
   in liftIO $ KafkaProducer <$> prod

send :: MonadIO m
     => KafkaProducer
     -> ProducerRecord
     -> m (JFuture JRecordMetadata)
send (KafkaProducer kp) r = liftIO $ rawSend kp (mkJProducerRecord r)

mkJProducerRecord :: ProducerRecord -> JProducerRecord JByteArray JByteArray
mkJProducerRecord (ProducerRecord t p k v) =
  let TopicName t' = t
      p' = (\(PartitionId x) -> x) <$> p
      k' = toJava . BS.unpack <$> k
      v' = toJava . BS.unpack <$> v
   in newJProducerRecord (toJString t') (toJava <$> p') Nothing k' v'

closeProducer :: MonadIO m => KafkaProducer -> m ()
closeProducer (KafkaProducer kp) = liftIO $ flushProducer kp >> destroyProducer kp

mkProducerProps :: ProducerProperties -> J.Map JString JString
mkProducerProps (ProducerProperties m) =
  toJava $ bimap toJString toJString <$> M.toList m
