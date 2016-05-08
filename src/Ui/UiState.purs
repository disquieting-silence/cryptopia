module Ui.UiState (recreate, create, modify, UpdateGameState, shiftFocus) where

import Core.Navigation
import Browser.Common
import Core.Crossword
import Ui.Ui

import Control.Monad.Eff
import Data.Maybe
import Prelude
import Data.Array((!!))

type UpdateGameState = { model :: Crossword, node :: Node, focused :: Maybe Node }

findAgain :: forall eff. Node -> { colIndex :: Int, rowIndex :: Int } -> Eff (dom :: DOM | eff) (Maybe Node)
findAgain container indices = do
  rows <- querySelectorAll container "tr"
  theRow <- pure $ (rows !! indices.rowIndex)
  cells <- maybe (pure []) (\r -> querySelectorAll r "td") theRow
  pure $ (cells !! indices.colIndex)

recreate :: forall eff. Crossword -> Eff (dom :: DOM | eff) UpdateGameState
recreate cword = do
  let ui = Ui.Ui.renderCrossword cword
  node <- renderNode ui
  pure { model: cword, node: node, focused: Nothing }


create :: forall eff. Bounds -> Eff (dom :: DOM | eff) UpdateGameState
create bounds =
  let cword = Core.Crossword.createGrid bounds.width bounds.height
  in recreate cword

renderNode :: forall eff. CrosswordUi -> Eff (dom :: DOM | eff) Node
renderNode (CrosswordUi model) = createElementsFrom model

modify :: forall eff. Node -> Crossword -> (CellIndex -> Crossword -> Crossword) -> Eff (dom :: DOM | eff) UpdateGameState
modify node cword modification = do
  indices <- Ui.Ui.readIndicesFromCell node
  let updated = Data.Maybe.maybe cword (\i -> modification i cword) indices
  recreated <- recreate updated
  focused <- Data.Maybe.maybe (pure Nothing) (\i -> findAgain recreated.node i) indices
  pure { model: recreated.model, node: recreated.node, focused: focused }

-- TODO: Make this return a GameState (which probably means it should take a GameState as an input)
shiftFocus :: forall eff. Node -> Node -> Crossword -> (Maybe Direction) -> Eff (dom :: DOM | eff) (Maybe Node)
shiftFocus container node cword dir = do
  indices <- Ui.Ui.readIndicesFromCell node
  newIndices <- pure $ Core.Navigation.processNavigation cword dir indices
  Data.Maybe.maybe (pure Nothing) (\i -> findAgain container i) newIndices
