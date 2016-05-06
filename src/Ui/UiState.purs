module Ui.UiState where

import Core.Crossword
import Browser.Common
import Ui.Ui

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
