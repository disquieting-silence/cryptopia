module Ui.Navigation where

import Ui.Common
import Browser.Common
import Core.Crossword
import Core.Navigation
import Data.Maybe
import Prelude
import Control.Monad.Eff

processDirection :: KeyEvent -> Maybe Direction
processDirection evt =
  case evt.which of
    37 -> Just West
    38 -> Just North
    39 -> Just East
    40 -> Just South
    _ -> Nothing

processKeydown :: forall eff. Node -> Crossword -> KeyEvent -> Eff (dom :: DOM | eff) (Maybe Node)
processKeydown container cword evt = do
  let dir = processDirection evt
  cellIndex <- Ui.Ui.readIndicesFromCell evt.target
  newFocus <- pure $ Core.Navigation.processNavigation cword dir cellIndex
  Data.Maybe.maybe (pure Nothing) (\i -> Ui.Common.findAgain container i) newFocus
