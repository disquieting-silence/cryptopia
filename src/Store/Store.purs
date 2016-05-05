module Store.Store where

import Browser.Storage(RawFormat, BrowserStorage, getFromStorage, putInStorage)
import Core.Crossword(parse, serialise, Crossword)
import Control.Monad.Eff
import Data.Maybe
import Prelude((<$>), bind, pure, Unit, ($))

-- Just started this module ... I don't think this is the right separation
-- either. Just playing around with it.
loadFromRawFormat :: RawFormat -> Crossword
loadFromRawFormat input = Core.Crossword.parse(input)

apiLoad :: forall eff. String -> Eff (browser :: BrowserStorage | eff) (Maybe Crossword)
apiLoad name = do
  input <- getFromStorage name
  pure $ (loadFromRawFormat <$> input.detail)

apiSave :: forall eff. String -> Crossword -> Eff (browser :: BrowserStorage | eff) Unit
apiSave name cword = do
  let toSave = Core.Crossword.serialise cword
  putInStorage name toSave
