{-# LANGUAGE MagicHash, FlexibleContexts, DataKinds, TypeFamilies, OverloadedStrings, ScopedTypeVariables #-}
module Main where

import Java
import Control.Monad(forM_)
import Data.Map (Map)
import qualified Data.Map as M
import Kafka.Consumer

consumerConf :: Map JString JString
consumerConf = M.fromList
  [ ("bootstrap.servers", "localhost:9092")
  , ("group.id", "test-group-0")
  , ("auto.offset.reset", "earliest")
  , ("enable.auto.commit", "false")
  ]

main :: IO ()
main = do
  cons <- java $ newBytesConsumer consumerConf
  _    <- javaWith cons $ subscribeTo [TopicName "attacks"]
  as   <- javaWith cons $ poll (Timeout 1000)
  print (show as)
  javaWith cons closeConsumer
  print "Ok."
