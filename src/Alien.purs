module Alien where

import Control.Monad.Eff (Eff)
import Prelude

foreign import data DOM :: !

type Point = { x :: Int, y :: Int }
type KeyEvent = { which :: Int }
type Bounds = { width :: Int, height :: Int }

type CryptopiaApi = {
  getNextPosition :: Point -> KeyEvent -> Bounds -> Point
}

foreign import doEverything :: forall eff. CryptopiaApi -> Eff (dom :: DOM | eff) Unit
