module Alien where

import Browser.Common
import Browser.Storage
import Control.Monad.Eff (Eff)
import Core.Crossword
import Prelude
import Data.Maybe

type Point = { x :: Int, y :: Int }
type KeyEvent = { which :: Int }
type Bounds = { width :: Int, height :: Int }

type CryptopiaApi = {
  getNextPosition :: Point -> KeyEvent -> Bounds -> Point,
  load :: forall eff. String -> Eff (dom :: DOM, browser :: BrowserStorage | eff) (Maybe { model :: Crossword, node :: Node }),
  save :: forall eff. String -> Crossword -> Eff (browser :: BrowserStorage | eff) Unit,
  update :: forall eff. Point -> Maybe String -> Eff (dom :: DOM | eff) Node,
  createGrid :: Bounds -> Crossword,
  renderGrid :: forall eff. Crossword -> Eff (dom :: DOM | eff) Node
}

foreign import doEverything :: forall eff. CryptopiaApi -> Eff (dom :: DOM | eff) Unit
