{-# LANGUAGE OverloadedStrings #-}

import Data.Monoid (mappend)
import Data.String.Utils (replace)
import Hakyll
import qualified Data.Set as S
import Text.Pandoc.Options

main :: IO ()
main = hakyll $ do
    index
    about
    burge
    posts
    memos
    archivePosts
    archiveBurge
    archiveMemos
    templates
    images
    css
    atom

-- Utility functions
------------------------------------------------------------------------------

(<>) = mappend


-- Use pandoc options to get typeset Mathematics
------------------------------------------------------------------------------

pandocMathCompiler = pandocCompilerWith defaultHakyllReaderOptions writerOpts
  where
    mathExtensions = [ Ext_tex_math_dollars, Ext_tex_math_double_backslash
                     , Ext_latex_macros
                     ]
    defaultExt     = writerExtensions defaultHakyllWriterOptions
    newExtensions  = foldr S.insert defaultExt mathExtensions
    writerOpts     = defaultHakyllWriterOptions {
                        writerExtensions = newExtensions, 
                        writerHTMLMathMethod = MathJax ""
                     }


images :: Rules ()
images = match "images/*" $ do
             route idRoute
             compile copyFileCompiler

templates :: Rules ()
templates = match "templates/*" $ compile templateCompiler

about :: Rules ()
about = match "about.markdown" $ do
            route $ setExtension "html"
            compile $ pandocCompiler
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= (return . removeIndexFromUrls)

memos :: Rules ()
memos = match "memos/*" $ do
            route $ composeRoutes (composeRoutes (gsubRoute "memos/" (const "")) (gsubRoute ".md" (const "/index.md"))) (setExtension "html")
            compile $ pandocMathCompiler
                >>= loadAndApplyTemplate "templates/post.html" postCtx
                >>= saveSnapshot "memoContent"
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls

posts :: Rules ()
posts = match "posts/*" $ do
            route $ composeRoutes (composeRoutes (gsubRoute "posts/" (const "")) (gsubRoute ".md" (const "/index.md"))) (setExtension "html")
            compile $ pandocMathCompiler
                >>= loadAndApplyTemplate "templates/post.html" postCtx
                >>= saveSnapshot "postContent"
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls

burge :: Rules ()
burge = match "burge/*" $ do
            route $ composeRoutes (composeRoutes (gsubRoute "burge/" (const "")) (gsubRoute ".md" (const "/index.md"))) (setExtension "html")
            compile $ pandocMathCompiler
                >>= loadAndApplyTemplate "templates/post.html" postCtx
                >>= saveSnapshot "postContent"
                >>= loadAndApplyTemplate "templates/default.html" defaultContext
                >>= relativizeUrls

archivePosts :: Rules ()
archivePosts = create ["posts.html"] $ do
            route idRoute
            compile $ do
                posts <- recentFirst =<< loadAll "posts/*"
                let ctx = constField "title" "Posts" <>
                            listField "posts" postCtx (return posts) <>
                            defaultContext
                makeItem ""
                    >>= loadAndApplyTemplate "templates/posts.html" ctx
                    >>= loadAndApplyTemplate "templates/default.html" ctx
                    >>= relativizeUrls
archiveBurge :: Rules ()
archiveBurge = create ["burge.html"] $ do
            route idRoute
            compile $ do
                posts <- chronological =<< loadAll "burge/*"
                let ctx = constField "title" "Burge School of Functional Programming" <>
                            listField "posts" postCtx (return posts) <>
                            defaultContext
                makeItem ""
                    >>= loadAndApplyTemplate "templates/posts.html" ctx
                    >>= loadAndApplyTemplate "templates/default.html" ctx
                    >>= relativizeUrls

archiveMemos :: Rules ()
archiveMemos = create ["memos.html"] $ do
            route idRoute
            compile $ do
                posts <- recentFirst =<< loadAll "memos/*"
                let ctx = constField "title" "Memos" <>
                            listField "posts" postCtx (return posts) <>
                            defaultContext
                makeItem ""
                    >>= loadAndApplyTemplate "templates/posts.html" ctx
                    >>= loadAndApplyTemplate "templates/default.html" ctx
                    >>= relativizeUrls

index :: Rules ()
index = create ["index.html"] $ do
            route idRoute
            compile $ do
                blogPosts <- recentFirst =<< loadAll "posts/*"
                burgePosts <- recentFirst =<< loadAll "burge/*"
                memoPosts <- recentFirst =<< loadAll "memos/*"
                let indexContext = listField "posts" postCtx (return blogPosts) `mappend`
                                   listField "burge" postCtx (return burgePosts) `mappend`
                                   listField "memos" postCtx (return memoPosts) `mappend`
                                   defaultContext
                makeItem "" >>= loadAndApplyTemplate "templates/index.html" indexContext
                >>= loadAndApplyTemplate "templates/default.html" (constField "title" "JMCT" `mappend` defaultContext)
                >>= (return . removeIndexFromUrls)


matchCss :: Rules ()
matchCss =  match "css/*" $ compile getResourceBody

buildConcatenatedCss :: Rules ()
buildConcatenatedCss = create ["site.css"] $ do
                         route $ constRoute "css/site.css"
                         compile concatenateAndCompress

concatenateCss :: Compiler (Item [Char])
concatenateCss = do
    items <- loadCss
    makeItem $ concatMap itemBody (items :: [Item String])

concatenateAndCompress :: Compiler (Item String)
concatenateAndCompress = concatenateCss >>= (return . compressCssItem)

compressCssItem :: (Item String) -> (Item String)
compressCssItem = fmap compressCss

-- Explicitly load the css in this order, as it's
-- the order we want to concatenate them in
loadCss :: Compiler [Item String]
loadCss = mapM load ["css/normalize.css",
                      "css/syntax.css",
                      "css/application.css"]

css :: Rules ()
css = matchCss >> buildConcatenatedCss

removeIndexFromUrls :: (Item String) -> (Item String)
removeIndexFromUrls = fmap $ withUrls (replace "index.html" "")

postCtx :: Context String
postCtx =
    dateField "date" "%b %e, %Y" `mappend`
    defaultContext

feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration
    { feedTitle         = "JMCT: FP"
    , feedDescription   = "JMCT on functional programming"
    , feedAuthorName    = "JMCT"
    , feedAuthorEmail   = "jmct@jmct.cc"
    , feedRoot          = "http://jmct.cc"
    }

atom :: Rules ()
atom = create ["atom.xml"] $ do
           route idRoute
           compile $ do
               let feedCtx = postCtx `mappend` bodyField "description"
               blogPosts <- fmap (take 10) . recentFirst =<<
                   loadAllSnapshots "posts/*" "postContent"
               renderAtom feedConfiguration feedCtx blogPosts
