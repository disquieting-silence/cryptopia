module Core.Crossword where

import Data.Maybe

data CrosswordSquare =
  Void |
  Empty { num :: Maybe Int } |
  Full { num :: Maybe Int }


data Crossword = Crossword (Array CrosswordSquare)


parse :: Array (Array String) -> Crossword
parse rows = Crossword [ ]
