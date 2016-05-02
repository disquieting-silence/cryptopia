module Browser.Storage where

import Control.Monad.Eff (Eff)
import Prelude(Unit)
import Data.Maybe

foreign import data BrowserStorage :: !

type RawFormat = Array (Array String)

foreign import putInStorage :: forall eff. String -> RawFormat -> Eff (browser :: BrowserStorage | eff) Unit

foreign import getFromStorage :: forall eff. String -> Eff (browser :: BrowserStorage | eff) { detail :: (Maybe RawFormat) }


-- I need this because when I have an Eff Maybe it is making the <- operate
-- on the maybe instead of the Eff. Therefore, I'm going to translate it to
-- a type that doesn't have bind.

-- loadFromStorage :: forall eff. String -> Eff (browser :: BrowserStorage | eff) StorageOperation
-- loadFromStorage name =
