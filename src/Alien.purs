module Alien where

import Control.Monad.Eff (Eff)
import Prelude

foreign import data DOM :: !

foreign import doEverything :: forall eff. Eff (dom :: DOM | eff) Unit
