{-# LANGUAGE TupleSections, OverloadedStrings #-}
module Handler.Wandbox where

import Import
import qualified Yesod                                  as Y

import Settings (widgetFile)
import Foundation (Handler, Route(StaticR))
import Settings.StaticFiles (io_2012_slides_js_require_1_0_8_min_js)

getWandboxR :: Handler Y.Html
getWandboxR = do
    Y.defaultLayout $ do
        Y.setTitle "Wandbox"
        Y.addScriptAttrs
            (StaticR io_2012_slides_js_require_1_0_8_min_js)
            [("data-main", "static/js/wandbox-slides")]
        $(widgetFile "wandbox")
