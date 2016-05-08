module Ui.Actions where

import Browser.Common
import Browser.Storage
import Core.Crossword
import Core.Navigation
import Ui.Ui
import Control.Monad.Eff
import Data.Maybe
import Data.Array
import Prelude(bind, pure, ($), id, negate, mod, (+), Unit, (<$>))
import Ui.Common
import Ui.Navigation
import Ui.UiState

modifySquare :: Int -> (CrosswordSquare -> CrosswordSquare)
modifySquare 32 = Core.Crossword.toBlank
modifySquare num =
  let letter = (Data.Char.fromCharCode num)
  in case letter of
       '.' -> Core.Crossword.toBlack
       _ ->   Core.Crossword.toLetter letter

processKeypress :: forall eff. KeyEvent -> Crossword -> Eff (dom :: DOM | eff) UpdateGameState
processKeypress evt cword = do
  let modifier = modifySquare (evt.which)
  let modification = (\i c -> updateGrid c i.rowIndex i.colIndex modifier)
  Ui.UiState.modify evt.target cword modification

processKeydown :: forall eff. Node -> Crossword -> KeyEvent -> Eff (dom :: DOM | eff) (Maybe Node)
processKeydown container cword evt = Ui.Navigation.processKeydown container cword evt

createGrid :: forall eff. Bounds -> Eff (dom :: DOM | eff) UpdateGameState
createGrid bounds = Ui.UiState.create bounds

loadGrid :: forall eff. String -> Eff (dom :: DOM, browser :: BrowserStorage | eff) (Maybe UpdateGameState)
loadGrid name = do
  mcword <- Store.LocalStore.apiLoad name
  maybe (pure Nothing) (\cword -> Just <$> Ui.UiState.recreate cword) mcword

saveGrid :: forall eff. String -> Crossword -> Eff (browser :: BrowserStorage | eff) Unit
saveGrid name cword = do
  let toSave = Core.Crossword.serialise cword
  putInStorage name toSave
