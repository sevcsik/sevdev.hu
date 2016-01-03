{-# LANGUAGE OverloadedStrings #-}

import           Data.Monoid (mappend)
import           Hakyll
import           Data.Maybe (fromMaybe)
import qualified Data.Map as M

postCtx :: Context String
postCtx = ( mconcat 
    [ dateField "date" "%B %e, %Y"
    , constField "base" ".."
    , constField "index" "0"
    , field "title" $ \item -> do
        metadata <- getMetadata (itemIdentifier item)
        return $ fromMaybe "" $ M.lookup "title" metadata
    , field "titleLength" $ \item -> do
        metadata <- getMetadata (itemIdentifier item)
        return $ 
            if (< 16) . length . (fromMaybe "") $ M.lookup "title" metadata
            then "short"
            else "long"
    , defaultContext
    ] )

-- borrowed from https://github.com/travisbrown/metaplasm
getTeaser :: Item String -> Item String
getTeaser = fmap (unlines . takeWhile (/= "<!-- TEASER -->") . lines)

feedConfig = FeedConfiguration
    { feedTitle       = "sevdev blog"
    , feedDescription = ""
    , feedAuthorName  = "Andras Sevcsik"
    , feedAuthorEmail = "sevcsik@sevdev.hu"
    , feedRoot        = "https://sevdev.hu/~sevcsik"
    }

main :: IO ()
main = hakyll $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "posts/*" $ do
        route $ setExtension "html"

        compile $ do
            compiled <- pandocCompiler
            teaser <- loadAndApplyTemplate "templates/inline-post.html" postCtx $ 
                getTeaser compiled
            full <- loadAndApplyTemplate "templates/post.html" postCtx compiled

            saveSnapshot "full" full
            saveSnapshot "teaser" teaser
            saveSnapshot "plain" compiled
            loadAndApplyTemplate "templates/default.html" postCtx full
                >>= relativizeUrls

    create ["index.html"] $ do
        route idRoute
        compile $ do
            let ctx = constField "title" "Home"               `mappend`
                      constField "base" "."                   `mappend` 
                      constField "index" "0"                  `mappend`
                      defaultContext
            makeItem ""
                >>= loadAndApplyTemplate "templates/splash.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls
  
    create ["latest.html"] $ do
        route idRoute
        compile $ do
            tpl <- loadBody "templates/post-item.html" 
            let ctx =
                    constField "title" "Latest posts"         `mappend`
                    constField "base" "."                     `mappend`
                    constField "index" "1"                    `mappend`
                    defaultContext

            loadAllSnapshots "posts/*" "teaser"
                >>= fmap (take 3) . recentFirst
                >>= applyTemplateList tpl postCtx
                >>= makeItem
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let ctx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archive"             `mappend`
                    constField "base" "."                    `mappend`
                    constField "index" "3"                   `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/post-list.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls


    match "about.md" $ do
        route $ setExtension "html"
        compile $ do
            let ctx =
                    constField "title" "Home"                `mappend`
                    constField "base" "."                    `mappend`
                    constField "index" "3"                   `mappend`
                    defaultContext

            pandocCompiler
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler   
    
    create ["rss.xml"] $ do
        route idRoute
        compile $ do
            let ctx = postCtx `mappend` bodyField "description"
            posts <- fmap (take 20) . recentFirst =<<
                loadAllSnapshots "posts/*" "plain"
            renderRss feedConfig ctx posts

    create ["atom.xml"] $ do
        route idRoute
        compile $ do
            let ctx = postCtx `mappend` bodyField "description"
            posts <- fmap (take 20) . recentFirst =<<
                loadAllSnapshots "posts/*" "plain"
            renderAtom feedConfig ctx posts
      
