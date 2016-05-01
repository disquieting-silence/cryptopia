module Core.Ui where

import Core.Crossword
import Browser.Common
import Prelude (void, map, show)
import Data.Maybe

data CrosswordUi = CrosswordUi NodeModel

data NodeModel = NodeModel {
  tag :: NodeTag,
  attributes :: Array Attribute,
  content :: HtmlContent,
  children :: Array NodeModel
}

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
  children: [ ]
}

renderNumber :: Maybe Int -> NodeModel
renderNumber numOpt = NodeModel {
  tag: "span",
  attributes: [
    { key: "class", value: "num" }
  ],
  content: maybe "" show numOpt,
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
    (renderContent "\\uFEFF")
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
renderCrosswordSquare Void = renderVoid
renderCrosswordSquare (Empty detail) = renderEmpty detail.num
renderCrosswordSquare (Full detail) = renderFull detail.content detail.num

renderCrosswordRow :: Array CrosswordSquare -> NodeModel
renderCrosswordRow xs =
  let squares = map renderCrosswordSquare xs
  in NodeModel {
    tag: "tr",
    attributes: [ ],
    content: "",
    children: squares
  }

renderCrossword :: Crossword -> CrosswordUi
renderCrossword (Crossword rowsData) =
  let rows = map renderCrosswordRow rowsData
      tbody = NodeModel { tag: "tbody", attributes: [ ], content: "", children: rows }
      table = NodeModel { tag: "table", attributes: [ ], content: "", children: [ tbody ] }
  in CrosswordUi table
