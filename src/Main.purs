module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Maybe
import Data.Array
import Data.Char
import Data.Foldable
import Math
import Data.Int

import Browser.Common
import Browser.Storage
import Core.Crossword
import Store.LocalStore
import Alien
import Ui.Actions
import Ui.Ui
import Ui.UiState

apiFailedLoad :: forall eff. String -> Eff (dom :: DOM | eff) (Maybe UpdateGameState)
apiFailedLoad name = do
  return Nothing

apiLoad :: forall eff. String -> Eff (dom :: DOM, browser :: BrowserStorage | eff) (Maybe UpdateGameState)
apiLoad name = do
  model <- Store.LocalStore.apiLoad name
  maybe (apiFailedLoad name) (\cword -> Just <$> Ui.UiState.recreate cword) model

apiSave :: forall eff. String -> Crossword -> Eff (browser :: BrowserStorage | eff) Unit
apiSave name cword = do
  let toSave = Core.Crossword.serialise cword
  putInStorage name toSave


apiUpdate :: forall eff. Node -> Crossword -> (CrosswordSquare -> CrosswordSquare) -> Eff (dom :: DOM | eff) UpdateGameState
apiUpdate = Ui.Actions.apiUpdate

processKeypress :: forall eff. KeyEvent -> Crossword -> Eff (dom :: DOM | eff) UpdateGameState
processKeypress = Ui.Actions.processKeypress

apiCreateGrid :: Bounds -> Crossword
apiCreateGrid= Ui.Actions.apiCreateGrid

apiRenderGrid :: forall eff. Crossword -> Eff (dom :: DOM | eff) Node
apiRenderGrid cword = Ui.Actions.apiRenderGrid cword

bridgeApi :: CryptopiaApi
bridgeApi = {
  load: apiLoad,
  save: apiSave,
  processKeypress: processKeypress,
  processKeydown: processKeydown,
  createGrid: apiCreateGrid,
  renderGrid: apiRenderGrid
}

main :: forall e. Eff (console :: CONSOLE, dom :: DOM, browser :: BrowserStorage | e) Unit
main = do
  doEverything (bridgeApi)
  putInStorage "dog" [[ "a" ]]
  log "HI"
