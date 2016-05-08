module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Maybe
import Alien
import Ui.Actions
import Browser.Common
import Browser.Storage

ffApi :: CryptopiaApi
ffApi = {
  load: Ui.Actions.loadGrid,
  save: Ui.Actions.saveGrid,
  processKeypress: Ui.Actions.processKeypress,
  processKeydown: Ui.Actions.processKeydown,
  createGrid: Ui.Actions.createGrid
}

main :: forall e. Eff (console :: CONSOLE, dom :: DOM, browser :: BrowserStorage | e) Unit
main = do
  doEverything (ffApi)
  putInStorage "dog" [[ "a" ]]
  log "HI"
