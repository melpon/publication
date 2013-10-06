{-# LANGUAGE TupleSections, OverloadedStrings #-}
module Handler.Wandbox where

import Import
import qualified Yesod                                  as Y

import Settings (widgetFile)
import Foundation (Handler, Widget, Route(StaticR))
import Settings.StaticFiles (io_2012_slides_js_require_1_0_8_min_js, img_wandbox_actor_png)
import RawString (rawstring)

widgetUI :: Widget
widgetUI = $(widgetFile "wandbox-ui")

widgetInternal :: Widget
widgetInternal = $(widgetFile "wandbox-internal")

sourceHamletSample1 :: String
sourceHamletSample1 = [rawstring|
<div .span2 #editor-settings>
  <label .row-fluid>choose key binding:
  <select .span12 size=3>
    <option value="ace" selected>default
    <option value="vim">Vim
    <option value="emacs">Emacs
  <label .checkbox>
    <input type="checkbox" value="use-legacy-editor">Use Legacy Editor
|]

sourceHamletSample1Html :: String
sourceHamletSample1Html = [rawstring|
<div class="span2" id="editor-settings">
  <label class="row-fluid">choose key binding:</label>
  <select class="span12" size=3>
    <option value="ace" selected>default</option>
    <option value="vim">Vim</option>
    <option value="emacs">Emacs</option>
  </select>
  <label class="checkbox">
    <input type="checkbox" value="use-legacy-editor">Use Legacy Editor</input>
  </label>
</div>
|]

sourceHamletSample2 :: String
sourceHamletSample2 = [rawstring|
<div .row-fluid>
  <div #compile-options>
    $forall info <- compilerInfos
      <div compiler="#{verName $ ciVersion info}">
        $forall sw <- ciSwitches info
          ^{makeSwitch (verName (ciVersion info)) sw}
|]

sourceLuciusSample :: String
sourceLuciusSample = [rawstring|
@textcolor: #ccc;
body {
  color: #{textcolor};
  a {
    color: #{textcolor};
  }
}
|]

sourceLuciusSampleCss :: String
sourceLuciusSampleCss = [rawstring|
body {
  color: #ccc;
}
body a {
  color: #ccc;
}
|]

sourceJuliusSample :: String
sourceJuliusSample = [rawstring|
$(function() {
  var result_container = new ResultContainer('#result-container')
  result_container.onfinish = function() {
    $('#compile').show();
    $('#compiling').hide();
  };
  ...
  var compiler = new Compiler('#compiler', '#compile-options');
  compiler.set_compiler(#{defaultCompiler});
});
|]

sourceLoopSample :: String
sourceLoopSample = [rawstring|
main = mapM_ print [1..]
|]

getWandboxR :: Handler Y.Html
getWandboxR = do
    Y.defaultLayout $ do
        Y.setTitle "Wandbox"
        Y.addScriptAttrs
            (StaticR io_2012_slides_js_require_1_0_8_min_js)
            [("data-main", "static/js/wandbox-slides")]
        $(widgetFile "wandbox")
