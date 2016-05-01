module Browser.Storage where

import Control.Monad.Eff (Eff)
import Prelude(Unit)
import Data.Maybe

foreign import data BrowserStorage :: !

type RawFormat = Array (Array String)

foreign import putInStorage :: forall eff. String -> RawFormat -> Eff (b :: BrowserStorage | eff) Unit

foreign import getFromStorage :: forall eff. String -> Eff (b :: BrowserStorage | eff) (Maybe RawFormat)
