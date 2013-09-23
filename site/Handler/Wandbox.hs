{-# LANGUAGE TupleSections, OverloadedStrings #-}
module Handler.Wandbox where

import Import

getWandboxR :: Handler Html
getWandboxR = do
    defaultLayout $ do
        setTitle "Wandbox"
        $(widgetFile "wandbox")
