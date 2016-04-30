module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Maybe

import Alien

type Point = { x :: Int, y :: Int }
type KeyEvent = { which :: Int }
type Bounds = { width :: Int, height :: Int }

cat :: Int -> Int
cat x = x + 1

main :: forall e. Eff (console :: CONSOLE, dom :: DOM | e) Unit
main = do
  log "Hello sailor!"
  doEverything ({ getName: "dog" })

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
  -- var delta = (function () {
  --   if (event.which === 37) return { x: -1, y: 0 };
  --   else if (event.which === 39) return { x: +1, y: 0 };
  --   else if (event.which === 38) return { x: 0, y: -1 };
  --   else if (event.which === 40) return { x: 0, y: +1 };
  --   else return { x: 0, y: 0 };
  -- })();
  --
  -- var nextRow = ((row + delta.y) + NUM_ROWS) % NUM_ROWS;
  -- var nextCol = ((column + delta.x) + NUM_COLS) % NUM_COLS;
