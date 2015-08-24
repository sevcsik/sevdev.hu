{-# LANGUAGE OverloadedStrings #-}

import           Data.Monoid (mappend)
import           Hakyll
import           Data.Maybe (fromMaybe)
import qualified Data.Map as M

postCtx :: Context String
postCtx = mconcat 
    [ dateField "date" "%B %e, %Y"
    , field "title" $ \item -> do
        metadata <- getMetadata (itemIdentifier item)
        return $ fromMaybe "" $ M.lookup "title" metadata
    , defaultContext
    ]

-- borrowed from https://github.com/travisbrown/metaplasm
getTeaser :: Item String -> Item String
getTeaser = fmap (unlines . takeWhile (/= "<!-- TEASER -->") . lines)

main :: IO ()
main = hakyll $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
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
            loadAndApplyTemplate "templates/default.html" postCtx full
                >>= relativizeUrls

    create ["index.html"] $ do
        route idRoute
        compile $ do
            tpl <- loadBody "templates/post-item.html" 
            let ctx =
                    constField "title" "Latest"              `mappend`
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
                    defaultContext

            pandocCompiler
                >>= applyAsTemplate ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler
