{-# LANGUAGE TupleSections, OverloadedStrings #-}
module Handler.Wandbox where

import Import
import qualified Yesod                                  as Y

import Settings (widgetFile)
import Foundation (Handler)

getWandboxR :: Handler Y.Html
getWandboxR = do
    Y.defaultLayout $ do
        Y.setTitle "Wandbox"
        $(widgetFile "wandbox")
