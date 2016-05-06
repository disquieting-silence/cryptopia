module Ui.UiState where

import Core.Crossword
import Browser.Common
import Ui.Ui
import Ui.Common

import Control.Monad.Eff
import Data.Maybe
import Prelude

type UpdateGameState = { model :: Crossword, node :: Node, focused :: Maybe Node }

recreate :: forall eff. Crossword -> Eff (dom :: DOM | eff) UpdateGameState
recreate cword = do
  let ui = Ui.Ui.renderCrossword cword
  node <- renderNode ui
  pure { model: cword, node: node, focused: Nothing }

renderNode :: forall eff. CrosswordUi -> Eff (dom :: DOM | eff) Node
renderNode (CrosswordUi model) = createElementsFrom model

modify :: forall eff. Node -> Crossword -> (CellIndex -> Crossword -> Crossword) -> Eff (dom :: DOM | eff) UpdateGameState
modify node cword modification = do
  rowIndex <- (readAttribute node "data-row-index")
  colIndex <- (readAttribute node "data-col-index")
  let indices = readIndices rowIndex colIndex
  let updated = Data.Maybe.maybe cword (\i -> modification i cword) indices
  recreated <- recreate updated
  focused <- Data.Maybe.maybe (pure Nothing) (\i -> findAgain recreated.node i) indices
  pure { model: recreated.model, node: recreated.node, focused: focused }
