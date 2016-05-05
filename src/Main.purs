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
import Core.Ui
import Alien
import Ui.Actions

data Navigation = North | East | South | West


loadFromRawFormat :: RawFormat -> CrosswordUi
loadFromRawFormat input =
  let model = Core.Crossword.parse input
  in Core.Ui.renderCrossword model

apiLoadFrom :: forall eff. RawFormat -> Eff (dom :: DOM | eff) (Maybe UpdateGameState)
apiLoadFrom raw =
  let info = loadFromRawFormat raw
  in (\i -> Just { model: Core.Crossword.parse raw, node: i, focused: Nothing}) <$> (renderNode info)

apiFailedLoad :: forall eff. String -> Eff (dom :: DOM | eff) (Maybe UpdateGameState)
apiFailedLoad name = do
  return Nothing

apiLoad :: forall eff. String -> Eff (dom :: DOM, browser :: BrowserStorage | eff) (Maybe UpdateGameState)
apiLoad name = do
  input <- getFromStorage name
  maybe (apiFailedLoad name) apiLoadFrom input.detail

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
