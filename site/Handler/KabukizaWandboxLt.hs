{-# LANGUAGE OverloadedStrings #-}
module Handler.KabukizaWandboxLt where

import Import
import qualified Yesod                                  as Y

import Yesod (shamlet)

import Settings (widgetFile)
import Foundation (Handler, Route(StaticR), Widget)
import Settings.StaticFiles
  ( io_2012_slides_js_require_1_0_8_min_js
  )

toTakahashi :: String -> Widget
toTakahashi message = Y.toWidget [shamlet|
<slide>
  <article .takahashi .flexbox .vcenter>
    <h1>#{message}
|]

-- Important version
toTakahashiI :: String -> Widget
toTakahashiI message = Y.toWidget [shamlet|
<slide>
  <article .takahashi .important .flexbox .vcenter>
    <h1 .red>#{message}
|]

toWandboxURL :: Widget
toWandboxURL = Y.toWidget [shamlet|
<slide>
  <article .takahashi .flexbox .vcenter>
    <h1><a href="http://melpon.org/wandbox">http://melpon.org/wandbox</a>
|]

getKabukizaWandboxLtR :: Handler Y.Html
getKabukizaWandboxLtR = do
    Y.defaultLayout $ do
        Y.setTitle "Wandbox の紹介 at 歌舞伎座.tech#2"
        Y.addScriptAttrs
            (StaticR io_2012_slides_js_require_1_0_8_min_js)
            [("data-main", "static/js/kabukiza-wandbox-lt-slides")]
        $(widgetFile "io-2012-ext")
        $(widgetFile "kabukiza-wandbox-lt")
