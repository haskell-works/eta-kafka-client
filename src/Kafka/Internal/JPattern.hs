{-# LANGUAGE MagicHash, FlexibleContexts, DataKinds, TypeFamilies #-}
module Kafka.Internal.JPattern
where

--
import Java

data {-# CLASS "java.util.regex.Pattern" #-} JPattern = JPattern (Object# JPattern)
  deriving Class

foreign import java unsafe "@static java.util.regex.Pattern.compile"
  newPattern  :: JString -> Java a JPattern
