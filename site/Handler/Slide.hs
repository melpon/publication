{-# LANGUAGE OverloadedStrings #-}
module Handler.Slide
  ( Index(..)
  , Title(..)
  , indexToWidget
  , getTitleWidget
  ) where

import Import
import qualified Data.List                              as List
import qualified Data.Monoid                            as Monoid
import qualified Text.Blaze.Internal                    as BlazeInternal
import qualified Text.Blaze.Html5                       as Html5
import qualified Text.Blaze.Html5.Attributes            as Html5Attr
import qualified Yesod.Core.Widget                      as YWidget

import Text.Lucius (lucius)

import Foundation (Widget)

data Index = Index String [Title]
data Title = TitleOnly (String, String) | Title (String, String) [Title]

slide :: Html5.Html -> Html5.Html
slide = BlazeInternal.Parent "slide" "<slide" "</slide>"

indexToWidget :: Index -> Maybe String -> Widget
indexToWidget index mKey = do
    YWidget.toWidget $ indexToHtml index mKey
    YWidget.toWidget [lucius|
      .index .non-visible-text {
        color: rgba(121, 121, 121, 0.3);
      }
      .index .visible-text {
        color: rgba(121, 121, 121, 1.0);
      }
      |]

indexToHtml :: Index -> Maybe String -> Html5.Html
indexToHtml index@(Index name titles) mKey =
  slide Html5.! Html5Attr.class_ "index" $
    Monoid.mconcat
      [ Html5.hgroup $
          Html5.h2 $
            Html5.toHtml $ maybe name (getTitle index) mKey
      , Html5.article $
          snd $ makeUl titles
      ]
  where
    match key =
        case mKey of
          Nothing -> True
          (Just key') -> key == key'
    makeUl titles' =
      let pairs = map makeLi titles'
          matched = any fst pairs
          tags = map snd pairs
      in ( matched
         , Html5.ul $ Monoid.mconcat tags
         )
    getClass matched = Html5Attr.class_ (if matched then "visible-text" else "non-visible-text")
    makeLi (TitleOnly (key, title)) =
      let matched = match key
      in
        ( matched
        , Html5.li Html5.! (getClass $ match key) $
            Html5.toHtml title
        )
    makeLi (Title (key, title) subtitles) =
      let (matched, ul) = makeUl subtitles
          matched' = matched || match key
      in
        ( matched'
        , Html5.li Html5.! (getClass matched') $
            Monoid.mconcat [Html5.toHtml title, ul]
        )

getTitleWidget :: Index -> String -> Widget
getTitleWidget index key = YWidget.toWidget $ Html5.toHtml $ getTitle index key

getTitle :: Index -> String -> String
getTitle (Index _ titles) fkey = concat $ List.intersperse " - " $ concat $ map finds titles
  where
    match key = key == fkey
    finds (TitleOnly (key, title))
        | match key = [title]
        | otherwise = []
    finds (Title (key, title) titles')
        | match key = [title]
        | otherwise =
            case concat $ map finds titles' of
              [] -> []
              results -> title:results
