module Browser.Common where

import Control.Monad.Eff (Eff)
import Data.Tuple


foreign import data DOM :: !

foreign import data Node :: *

type NodeTag = String
type Attribute = { key :: String, value :: String }
type HtmlContent = String

foreign import createElement :: forall eff. NodeTag -> Array Attribute -> HtmlContent -> Eff (dom :: DOM | eff) Node
