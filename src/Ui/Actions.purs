module Ui.Actions where

import Browser.Common
import Core.Crossword
import Core.Navigation
import Ui.Ui
import Control.Monad.Eff
import Data.Maybe
import Data.Array
import Prelude(bind, pure, ($), id, negate, mod, (+))
import Ui.Common
import Ui.Navigation
import Ui.UiState

processKeydown :: forall eff. Node -> Crossword -> KeyEvent -> Eff (dom :: DOM | eff) (Maybe Node)
processKeydown container cword evt = Ui.Navigation.processKeydown container cword evt

modifySquare :: Int -> (CrosswordSquare -> CrosswordSquare)
modifySquare 32 = Core.Crossword.toBlank
modifySquare num =
  let letter = (Data.Char.fromCharCode num)
  in case letter of
       '.' -> Core.Crossword.toBlack
       _ ->   Core.Crossword.toLetter letter

processKeypress :: forall eff. KeyEvent -> Crossword -> Eff (dom :: DOM | eff) UpdateGameState
processKeypress evt cword = apiUpdate evt.target cword (modifySquare evt.which)

apiUpdate :: forall eff. Node -> Crossword -> (CrosswordSquare -> CrosswordSquare) -> Eff (dom :: DOM | eff) UpdateGameState
apiUpdate node cword modifier = do
  let modification = (\i c -> updateGrid c i.rowIndex i.colIndex modifier)
  Ui.UiState.modify node cword modification

apiRenderGrid :: forall eff. Crossword -> Eff (dom :: DOM | eff) Node
apiRenderGrid cword =
  let ui = Ui.Ui.renderCrossword cword
  in renderNode ui


apiCreateGrid :: Bounds -> Crossword
apiCreateGrid bounds = Core.Crossword.createGrid bounds.width bounds.height
