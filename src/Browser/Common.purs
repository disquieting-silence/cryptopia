module Browser.Common where

import Control.Monad.Eff (Eff)

foreign import data DOM :: !

foreign import data Node :: *

type NodeTag = String
type Class = String
type HtmlContent = String

foreign import createElement :: forall eff. NodeTag -> Array Class -> HtmlContent -> Eff (dom :: DOM | eff) Node
