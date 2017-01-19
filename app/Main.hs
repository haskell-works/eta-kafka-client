{-# LANGUAGE MagicHash, FlexibleContexts, DataKinds, TypeFamilies, OverloadedStrings, ScopedTypeVariables #-}
module Main where

import Java
import Control.Monad(forM_)
import Data.Map (Map)
import qualified Data.Map as M
import Kafka.Consumer

consumerConf :: Map JString JString
consumerConf = M.fromList [ ("bootstrap.servers", "localhost:9092") ]

main :: IO ()
main = do
  cons <- java $ newConsumer consumerConf
  print "Ok."
