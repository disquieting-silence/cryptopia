module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Maybe
import Data.Array
import Data.Foldable

import Alien

format :: Array (Array String) -> String
format info = Data.Foldable.intercalate "," (map (\r -> Data.Foldable.intercalate "," r) info)
--map (Data.Foldable.intercalate ",") info

main :: forall e. Eff (console :: CONSOLE, dom :: DOM, b :: BrowserStorage | e) Unit
main = do
  doEverything ({ getNextPosition: getNextPosition })
  putInStorage "dog" [[ "a" ]]
  info <- getFromStorage "dog"
  let strings = maybe "" format info
  -- let strings = Prelude.map (\row -> (Data.Foldable.intercalate row ",")) info
  -- let output = Data.Foldable.intercalate "," strings
  -- log output
  log strings

getDelta :: KeyEvent -> Maybe Point
getDelta evt =
  case evt.which of
    37 -> Just { x: -1, y : 0 }
    38 -> Just { x: 0, y: -1 }
    39 -> Just { x: 1, y: 0 }
    40 -> Just { x: 0, y: 1 }
    _ -> Nothing

getNextPosition :: Point -> KeyEvent -> Bounds -> Point
getNextPosition pt evt bounds =
  let delta = maybe { x: 0, y: 0 } id (getDelta evt)
      nextX = ((pt.x + delta.x) + bounds.width) `mod` bounds.width
      nextY = ((pt.y + delta.y) + bounds.height) `mod` bounds.height
  in { x: nextX, y: nextY }
