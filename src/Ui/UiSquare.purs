module Ui.UiSquare where

import Browser.Common
import Data.Maybe
import Prelude(show)

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
