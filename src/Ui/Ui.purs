module Ui.Ui where

import Core.Crossword
import Browser.Common
import Data.Array
import Data.Maybe
import Prelude (void, map, show, bind, pure, ($))
import Data.Int
import Control.Monad.Eff
import Ui.UiSquare

data CrosswordUi = CrosswordUi NodeModel

-- <td tabindex="-1" class="open"><span class="num">10</span><span class="square">D</span></td>
renderCrosswordSquare :: CrosswordSquare -> NodeModel
renderCrosswordSquare Black = Ui.UiSquare.renderVoid
renderCrosswordSquare (Empty detail) = Ui.UiSquare.renderEmpty detail.num
renderCrosswordSquare (Full detail) = Ui.UiSquare.renderFull detail.content detail.num

addAttrToModel :: NodeModel -> (Array Attribute) -> NodeModel
addAttrToModel (NodeModel base) attrs =
  NodeModel (base { attributes = (Data.Array.concat [base.attributes, attrs]) })

renderCrosswordSquareWithIndex :: { info :: CrosswordSquare, colIndex :: Int, rowIndex :: Int } -> NodeModel
renderCrosswordSquareWithIndex c =
  let base = renderCrosswordSquare c.info
  in addAttrToModel base [{ key: "data-col-index", value: (show c.colIndex) }, { key: "data-row-index", value: show c.rowIndex }]


renderCrosswordRow :: Int -> Array CrosswordSquare -> NodeModel
renderCrosswordRow r xs =
  let zipped = Data.Array.zipWith (\a b -> { rowIndex: r, colIndex: a, info: b }) (Data.Array.range 0 (Data.Array.length xs)) xs
      squares = map renderCrosswordSquareWithIndex zipped
  in NodeModel {
    tag: "tr",
    attributes: [ ],
    content: "",
    children: squares
  }

renderCrosswordRowWithIndex :: { row :: Array CrosswordSquare, rowIndex :: Int } -> NodeModel
renderCrosswordRowWithIndex i = renderCrosswordRow i.rowIndex i.row

renderCrossword :: Crossword -> CrosswordUi
renderCrossword (Crossword rowsData) =
  let zipped = Data.Array.zipWith (\a b -> { row: b, rowIndex: a }) (Data.Array.range 0 (Data.Array.length rowsData)) rowsData
      rows = map renderCrosswordRowWithIndex zipped
      tbody = NodeModel { tag: "tbody", attributes: [ ], content: "", children: rows }
      table = NodeModel { tag: "table", attributes: [ ], content: "", children: [ tbody ] }
  in CrosswordUi table

readIndices :: String -> String -> Maybe { colIndex:: Int, rowIndex:: Int }
readIndices rowIndex colIndex = do
  ri <- fromString rowIndex
  ci <- fromString colIndex
  pure { colIndex: ci, rowIndex: ri }

readIndicesFromCell :: forall eff. Node -> Eff (dom :: DOM | eff) (Maybe { colIndex :: Int, rowIndex :: Int })
readIndicesFromCell node = do
  rowIndex <- (readAttribute node "data-row-index")
  colIndex <- (readAttribute node "data-col-index")
  pure $ readIndices rowIndex colIndex
