module Core.Navigation where

import Prelude
import Core.Crossword
import Data.Maybe

data Direction = North | East | South | West

getDelta :: Direction -> CellIndex
getDelta dir =
  case dir of
    West -> { colIndex: -1, rowIndex : 0 }
    North -> { colIndex: 0, rowIndex: -1 }
    East -> { colIndex: 1, rowIndex: 0 }
    South -> { colIndex: 0, rowIndex: 1 }

    -- nextX = ((pt.x + delta.x) + bounds.width) `mod` bounds.width
    -- nextY = ((pt.y + delta.y) + bounds.height) `mod` bounds.height

navigate :: Crossword -> Direction -> CellIndex -> CellIndex
navigate cword dir coord =
  let bounds = maybe { width: 1, height: 1 } id (Core.Crossword.getBounds cword)
      delta = getDelta dir
      nextCol = ((coord.colIndex + delta.colIndex) + bounds.width) `mod` bounds.width
      nextRow = ((coord.rowIndex + delta.rowIndex) + bounds.height) `mod` bounds.height
  in { colIndex: nextCol, rowIndex: nextRow }


processNavigation :: Crossword -> Maybe Direction -> Maybe CellIndex -> Maybe CellIndex
processNavigation cword dir cellIndex = do
  d <- dir
  i <- cellIndex
  pure $ navigate cword d i
