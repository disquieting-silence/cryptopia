module Ui.Actions where

import Browser.Common
import Core.Crossword
import Core.Navigation
import Ui.Ui
import Alien
import Control.Monad.Eff
import Data.Maybe
import Data.Array
import Prelude(bind, pure, ($), id, negate, mod, (+))
import Ui.Common

processDirection :: KeyEvent -> Maybe Direction
processDirection evt =
  case evt.which of
    37 -> Just West
    38 -> Just North
    39 -> Just East
    40 -> Just South
    _ -> Nothing

processNavigation :: Crossword -> Maybe Direction -> Maybe CellIndex -> Maybe CellIndex
processNavigation cword dir cellIndex = do
  d <- dir
  i <- cellIndex
  pure $ Core.Navigation.navigate cword d i

processKeydown :: forall eff. Node -> Crossword -> KeyEvent -> Eff (dom :: DOM | eff) (Maybe Node)
processKeydown container cword evt = do
  let dir = processDirection evt
  cellIndex <- Ui.Ui.readIndicesFromCell evt.target
  newFocus <- pure $ processNavigation cword dir cellIndex
  Data.Maybe.maybe (pure Nothing) (\i -> findAgain container i) newFocus


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
  rowIndex <- (readAttribute node "data-row-index")
  colIndex <- (readAttribute node "data-col-index")
  let indices = readIndices rowIndex colIndex
  let updated = Data.Maybe.maybe cword (\i -> updateGrid cword i.rowIndex i.colIndex modifier) indices
  rendered <- apiRenderGrid updated
  focused <- Data.Maybe.maybe (pure Nothing) (\i -> findAgain rendered i) indices
  pure { model: updated, node: rendered, focused: focused }


apiRenderGrid :: forall eff. Crossword -> Eff (dom :: DOM | eff) Node
apiRenderGrid cword =
  let ui = Ui.Ui.renderCrossword cword
  in renderNode ui


renderNode :: forall eff. CrosswordUi -> Eff (dom :: DOM | eff) Node
renderNode (CrosswordUi model) = createElementsFrom model

apiCreateGrid :: Bounds -> Crossword
apiCreateGrid bounds = Core.Crossword.createGrid bounds.width bounds.height
