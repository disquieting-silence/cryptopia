module Alien where

import Browser.Common
import Browser.Storage
import Control.Monad.Eff (Eff)
import Core.Crossword
import Prelude
import Data.Maybe

type Point = { x :: Int, y :: Int }
type KeyEvent = { which :: Int, target :: Node }
type Bounds = { width :: Int, height :: Int }

type UpdateGameState = { model :: Crossword, node :: Node, focused :: Maybe Node }

type CryptopiaApi = {
  getNextPosition :: Point -> KeyEvent -> Bounds -> Point,
  load :: forall eff. String -> Eff (dom :: DOM, browser :: BrowserStorage | eff) (Maybe UpdateGameState),
  save :: forall eff. String -> Crossword -> Eff (browser :: BrowserStorage | eff) Unit,
  processKeypress :: forall eff. KeyEvent -> Crossword -> Eff (dom :: DOM | eff) UpdateGameState,
  createGrid :: Bounds -> Crossword,
  renderGrid :: forall eff. Crossword -> Eff (dom :: DOM | eff) Node
}

foreign import doEverything :: forall eff. CryptopiaApi -> Eff (dom :: DOM | eff) Unit
