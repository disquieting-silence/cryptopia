module Ui.Actions where

import Browser.Common
import Core.Crossword
import Core.Ui
import Alien
import Control.Monad.Eff
import Data.Maybe
import Data.Array
import Prelude(bind, pure, ($), id, negate, mod, (+))

processKeydown :: forall eff. Node -> Crossword -> KeyEvent -> Eff (dom :: DOM | eff) (Maybe Node)
processKeydown container cword evt = do
  -- Remove duplication and abstraction breaking.

  -- What I want to do here is get the bounds (somehow) and navigate the delta and
  -- find that cell in the container, and return it

  -- So let's assume I have the bounds.
  bounds <- pure $ maybe { width : 1, height: 1 } id (getBounds cword)
  indices <- Core.Ui.readIndicesFromCell evt.target
  Data.Maybe.maybe (pure Nothing) (\i -> getNextSquare container i evt bounds) indices

getNextSquare :: forall eff. Node -> { rowIndex :: Int, colIndex :: Int } -> KeyEvent -> Bounds -> Eff (dom :: DOM | eff) (Maybe Node)
getNextSquare container indices evt bounds =
  let nextPoint = getNextPosition { x: indices.colIndex, y: indices.rowIndex } evt bounds
  in findAgain container { colIndex: nextPoint.x, rowIndex: nextPoint.y }


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

findAgain :: forall eff. Node -> { colIndex :: Int, rowIndex :: Int } -> Eff (dom :: DOM | eff) (Maybe Node)
findAgain container indices = do
  rows <- querySelectorAll container "tr"
  theRow <- pure $ (rows !! indices.rowIndex)
  cells <- maybe (pure []) (\r -> querySelectorAll r "td") theRow
  pure $ (cells !! indices.colIndex)


apiRenderGrid :: forall eff. Crossword -> Eff (dom :: DOM | eff) Node
apiRenderGrid cword =
  let ui = Core.Ui.renderCrossword cword
  in renderNode ui


renderNode :: forall eff. CrosswordUi -> Eff (dom :: DOM | eff) Node
renderNode (CrosswordUi model) = createElementsFrom model

getDelta :: KeyEvent -> Maybe Point
getDelta evt =
  case evt.which of
    37 -> Just { x: -1, y : 0 }
    38 -> Just { x: 0, y: -1 }
    39 -> Just { x: 1, y: 0 }
    40 -> Just { x: 0, y: 1 }
    _ -> Nothing

getNextPosition :: Point -> KeyEvent -> Bounds -> Point
getNextPosition pt evt bounds =
  let delta = maybe { x: 0, y: 0 } id (getDelta evt)
      nextX = ((pt.x + delta.x) + bounds.width) `mod` bounds.width
      nextY = ((pt.y + delta.y) + bounds.height) `mod` bounds.height
  in { x: nextX, y: nextY }


apiCreateGrid :: Bounds -> Crossword
apiCreateGrid bounds = Core.Crossword.createGrid bounds.width bounds.height
