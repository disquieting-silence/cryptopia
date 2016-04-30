module Alien where

import Control.Monad.Eff (Eff)
import Prelude

foreign import data DOM :: !

type CryptopiaApi = { getName :: String }

foreign import doEverything :: forall eff. CryptopiaApi -> Eff (dom :: DOM | eff) Unit
