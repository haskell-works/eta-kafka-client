{-# LANGUAGE MagicHash, BangPatterns, FlexibleContexts, DataKinds, TypeFamilies, OverloadedStrings, ScopedTypeVariables #-}
module Main where

import Java
import Java.String
import GHC.Base

import Control.Monad(forM_)
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

  forM_ received (print . bytesToJString)
  print "Ok."

runProducer :: TopicName -> [String] -> IO ()
runProducer t msgs = java $ do
  prod <- newProducer producerConf
  let items = mkProdRecord t <$> msgs
  forM_ items (\x -> prod <.> send x)
  prod <.> closeProducer
  where
    mkProdRecord t v =
      let bytes = stringBytes v
       in ProducerRecord t Nothing (Just bytes) (Just bytes)


runConsumer :: TopicName -> IO [JByteArray]
runConsumer t = java $ do
  cons <- newConsumer consumerConf
  cons <.> subscribeTo [t]
  msgs <- cons <.> poll (Timeout 1000)
  return $ msgs >>= maybeToList . crValue

-- helpers
stringBytes :: String -> JByteArray
stringBytes s = JByteArray (getBytesUtf8# js)
  where !(JS# js) = toJString s

foreign import java unsafe "@new" bytesToJString :: JByteArray -> JString
