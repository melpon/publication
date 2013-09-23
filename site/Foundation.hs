module Foundation
  ( Y.Route(..)
  , App(..)
  , Handler
  , Widget
  , resourcesApp
  , getExtra
  ) where

import Import
import qualified Yesod                                  as Y
import qualified Yesod.Static                           as YStatic
import qualified Yesod.Default.Config                   as YDConfig
import qualified Yesod.Default.Util                     as YDUtil
import qualified Text.Jasmine                           as Jasmine
import qualified Text.Hamlet                            as Hamlet
import qualified System.Log.FastLogger                  as FastLogger

import Yesod.Static (Static)

import Settings (widgetFile, Extra(..), staticDir, staticRoot)
import Settings.Development (development)

-- | The site argument for your application. This can be a good place to
-- keep settings and values requiring initialization before your application
-- starts running, such as database connections. Every handler will have
-- access to the data present here.
data App = App
    { settings :: YDConfig.AppConfig YDConfig.DefaultEnv Extra
    , getStatic :: Static -- ^ Settings for static file serving.
    , appLogger :: FastLogger.Logger
    }

-- Set up i18n messages. See the message folder.
Y.mkMessage "App" "messages" "en"

-- This is where we define all of the routes in our application. For a full
-- explanation of the syntax, please see:
-- http://www.yesodweb.com/book/routing-and-handlers
--
-- Note that this is really half the story; in Application.hs, mkYesodDispatch
-- generates the rest of the code. Please see the linked documentation for an
-- explanation for this split.
Y.mkYesodData "App" $(Y.parseRoutesFile "config/routes")

type Form x = Hamlet.Html -> Y.MForm (Y.HandlerT App IO) (Y.FormResult x, Widget)

-- Please see the documentation for the Yesod typeclass. There are a number
-- of settings which can be configured by overriding methods here.
instance Y.Yesod App where
    approot = Y.ApprootMaster $ YDConfig.appRoot . settings

    -- Store session data on the client in encrypted cookies,
    -- default session idle timeout is 120 minutes
    makeSessionBackend _ = return Nothing

    defaultLayout widget = do
        master <- Y.getYesod
        mmsg <- Y.getMessage

        -- We break up the default layout into two components:
        -- default-layout is the contents of the body tag, and
        -- default-layout-wrapper is the entire page. Since the final
        -- value passed to hamletToRepHtml cannot be a widget, this allows
        -- you to use normal widget features in default-layout.

        pc <- Y.widgetToPageContent $ do
            $(widgetFile "default-layout")
        Y.giveUrlRenderer $(Hamlet.hamletFile "templates/default-layout-wrapper.hamlet")

    -- This is done to provide an optimization for serving static files from
    -- a separate domain. Please see the staticRoot setting in Settings.hs
    urlRenderOverride y (StaticR s) =
        Just $ uncurry (Y.joinPath y (Settings.staticRoot $ settings y)) $ Y.renderRoute s
    urlRenderOverride _ _ = Nothing

    -- This function creates static content files in the static folder
    -- and names them based on a hash of their content. This allows
    -- expiration dates to be set far in the future without worry of
    -- users receiving stale content.
    addStaticContent =
        YDUtil.addStaticContentExternal Jasmine.minifym genFileName staticDir (StaticR . flip YStatic.StaticRoute [])
      where
        -- Generate a unique filename based on the content itself
        genFileName lbs
            | development = "autogen-" ++ YStatic.base64md5 lbs
            | otherwise   = YStatic.base64md5 lbs

    -- Place Javascript at bottom of the body tag so the rest of the page loads first
    jsLoader _ = Y.BottomOfBody

    -- What messages should be logged. The following includes all messages when
    -- in development, and warnings and errors in production.
    shouldLog _ _source level =
        development || level == Y.LevelWarn || level == Y.LevelError

    makeLogger = return . appLogger

-- This instance is required to use forms. You can modify renderMessage to
-- achieve customized and internationalized form validation messages.
instance Y.RenderMessage App Y.FormMessage where
    renderMessage _ _ = Y.defaultFormMessage

-- | Get the 'Extra' value, used to hold data from the settings.yml file.
getExtra :: Handler Extra
getExtra = fmap (YDConfig.appExtra . settings) Y.getYesod

-- Note: previous versions of the scaffolding included a deliver function to
-- send emails. Unfortunately, there are too many different options for us to
-- give a reasonable default. Instead, the information is available on the
-- wiki:
--
-- https://github.com/yesodweb/yesod/wiki/Sending-email
