module Ui.Ui where

import Core.Crossword
import Browser.Common
import Data.Array
import Data.Maybe
import Prelude (void, map, show, bind, pure, ($))
import Data.Int
import Control.Monad.Eff

data CrosswordUi = CrosswordUi NodeModel


focusable :: Attribute
focusable = { key: "tabindex", value: "-1" }
renderVoid :: NodeModel
renderVoid = NodeModel {
  tag: "td",
  attributes: [
    { key: "class", value: "black" },
    focusable
  ],
  content : "",
  children: [
   (renderNumber Nothing),
    NodeModel {
      tag: "span",
      attributes: [ { key: "class", value: "square" } ],
      content: "\x200b",
      children: [ ]
    }
  ]
}

renderNumber :: Maybe Int -> NodeModel
renderNumber numOpt = NodeModel {
  tag: "span",
  attributes: [
    { key: "class", value: "num" }
  ],
  content: maybe "\x200b" show numOpt,
  children: [ ]
}

renderContent :: HtmlContent -> NodeModel
renderContent c = NodeModel {
  tag: "span",
  attributes: [
    { key: "class", value: "square" }
  ],
  content: c,
  children: [ ]
}

renderEmpty :: Maybe Int -> NodeModel
renderEmpty numOpt = NodeModel {
  tag: "td",
  attributes: [
    { key: "class", value: "open" },
    focusable
  ],
  content: "",
  children: [
    (renderNumber numOpt),
    (renderContent "\x200b")
  ]
}

renderFull :: HtmlContent -> Maybe Int -> NodeModel
renderFull c numOpt = NodeModel {
  tag: "td",
  attributes: [
    { key: "class", value: "open" },
    { key: "tabindex", value: "-1" }
  ],
  content: "",
  children: [
    (renderNumber numOpt),
    renderContent c
  ]
}


-- <td tabindex="-1" class="open"><span class="num">10</span><span class="square">D</span></td>
renderCrosswordSquare :: CrosswordSquare -> NodeModel
renderCrosswordSquare Black = renderVoid
renderCrosswordSquare (Empty detail) = renderEmpty detail.num
renderCrosswordSquare (Full detail) = renderFull detail.content detail.num

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
