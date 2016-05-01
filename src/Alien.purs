module Alien where

import Control.Monad.Eff (Eff)
import Prelude
import Data.Maybe

foreign import data DOM :: !
foreign import data BrowserStorage :: !

type Point = { x :: Int, y :: Int }
type KeyEvent = { which :: Int }
type Bounds = { width :: Int, height :: Int }

type CryptopiaApi = {
  getNextPosition :: Point -> KeyEvent -> Bounds -> Point
}

type RawFormat = Array (Array String)

foreign import doEverything :: forall eff. CryptopiaApi -> Eff (dom :: DOM | eff) Unit

foreign import putInStorage :: forall eff. String -> RawFormat -> Eff (b :: BrowserStorage | eff) Unit

foreign import getFromStorage :: forall eff. String -> Eff (b :: BrowserStorage | eff) (Maybe RawFormat)
