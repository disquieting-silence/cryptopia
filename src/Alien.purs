module Alien where

import Browser.Common
import Browser.Storage
import Control.Monad.Eff (Eff)
import Core.Crossword
import Prelude
import Data.Maybe
import Ui.UiState

type CryptopiaApi = {
  load :: forall eff. String -> Eff (dom :: DOM, browser :: BrowserStorage | eff) (Maybe UpdateGameState),
  save :: forall eff. String -> Crossword -> Eff (browser :: BrowserStorage | eff) Unit,
  processKeypress :: forall eff. KeyEvent -> Crossword -> Eff (dom :: DOM | eff) UpdateGameState,
  processKeydown :: forall eff. Node -> Crossword -> KeyEvent -> Eff (dom :: DOM | eff) (Maybe Node),
  createGrid :: Bounds -> Crossword,
  renderGrid :: forall eff. Crossword -> Eff (dom :: DOM | eff) Node
}

foreign import doEverything :: forall eff. CryptopiaApi -> Eff (dom :: DOM | eff) Unit
