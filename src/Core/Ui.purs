module Core.Ui where

import Core.Crossword
import Browser.Common
import Prelude (void, map, show)
import Data.Maybe

data CrosswordUi = CrosswordUi (Array (Array NodeModel))

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

renderCrossword :: Crossword -> CrosswordUi
renderCrossword (Crossword rows) =
  let ui = map (map renderCrosswordSquare) rows
  in CrosswordUi ui
