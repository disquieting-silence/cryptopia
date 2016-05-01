module Core.Crossword where

import Data.Maybe
import Prelude(map)

data CrosswordSquare =
  Void |
  Empty { num :: Maybe Int } |
  Full { content :: String, num :: Maybe Int }

data Crossword = Crossword (Array (Array CrosswordSquare))

parseSquare :: String -> CrosswordSquare
parseSquare "*" = Void
parseSquare "" = Empty { num: Nothing }
parseSquare c = Full { content: c, num: Nothing }

parseRow :: Array String -> Array CrosswordSquare
parseRow = map parseSquare

parse :: Array (Array String) -> Crossword
parse rows =
  let parsed = map parseRow rows
  in Crossword parsed
