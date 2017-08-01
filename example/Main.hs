{-# LANGUAGE MagicHash, BangPatterns, FlexibleContexts, DataKinds, TypeFamilies, OverloadedStrings, ScopedTypeVariables #-}
module Main where

import GHC.Base

import Control.Monad(forM_)
import Data.ByteString
import Data.Monoid
import Data.Maybe (maybeToList)

import Kafka.Consumer
import Kafka.Producer

consumerConf :: ConsumerProperties
consumerConf = consumerBrokersList [BrokerAddress "localhost:9092"]
            <> groupId (ConsumerGroupId "test-group-1")
            <> offsetReset Earliest
            <> noAutoCommit

producerConf :: ProducerProperties
producerConf = producerBrokersList [BrokerAddress "localhost:9092"]

testTopic  = TopicName "kafka-example-topic"

main :: IO ()
main = do
  print "Running producer..."
  runProducer testTopic ["one", "two", "three"]

  print "Running consumer..."
  received <- runConsumer testTopic

  forM_ received print
  print "Ok."

runProducer :: TopicName -> [ByteString] -> IO ()
runProducer t msgs = do
  prod <- newProducer producerConf
  let items = mkProdRecord t <$> msgs
  forM_ items (send prod)
  closeProducer prod
  where
    mkProdRecord t v = ProducerRecord t Nothing (Just v) (Just v)


runConsumer :: TopicName -> IO [ByteString]
runConsumer t = do
  cons <- newConsumer consumerConf
  subscribeTo cons [t]
  msgs <- poll cons (Millis 3000)
  closeConsumer cons
  return $ msgs >>= maybeToList . crValue

