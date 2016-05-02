module Browser.Common where

import Data.Tuple
import Data.Traversable
import Control.Monad.Eff (Eff)
import Prelude


foreign import data DOM :: !

foreign import data Node :: *

type NodeTag = String
type Attribute = { key :: String, value :: String }
type HtmlContent = String

data NodeModel = NodeModel {
  tag :: NodeTag,
  attributes :: Array Attribute,
  content :: HtmlContent,
  children :: Array NodeModel
}

foreign import createElement :: forall eff. NodeTag -> Array Attribute -> HtmlContent -> Eff (dom :: DOM | eff) Node

foreign import appendElement :: forall eff. Node -> Node -> Eff (dom :: DOM | eff) Unit

foreign import readAttribute :: forall eff. Node -> String -> Eff (dom :: DOM | eff) String

createAndAppend :: forall eff. Node -> NodeModel -> Eff (dom :: DOM | eff) Unit
createAndAppend parent childModel = do
  c <- createElementsFrom childModel
  appendElement parent c

createElementsFrom :: forall eff. NodeModel -> Eff (dom :: DOM | eff) Node
createElementsFrom (NodeModel model) = do
  parent <- createElement model.tag model.attributes model.content
  children <- Data.Traversable.traverse (createAndAppend parent) model.children
  return parent
