module Core.Crossword where

import Data.Maybe
import Prelude

data CrosswordSquare =
  Black |
  Empty { num :: Maybe Int } |
  Full { content :: String, num :: Maybe Int }

data Crossword = Crossword (Array (Array CrosswordSquare))

parseSquare :: String -> CrosswordSquare
parseSquare "*" = Black
parseSquare "" = Empty { num: Nothing }
parseSquare c = Full { content: c, num: Nothing }

parseRow :: Array String -> Array CrosswordSquare
parseRow = map parseSquare

parse :: Array (Array String) -> Crossword
parse rows =
  let parsed = map parseRow rows
  in Crossword parsed

serialiseSquare :: CrosswordSquare -> String
serialiseSquare Black = "*"
serialiseSquare (Empty _) = ""
serialiseSquare (Full d) = d.content

serialise :: Crossword -> Array (Array String)
serialise (Crossword cword) = map (map serialiseSquare) cword

createRow :: Int -> Array CrosswordSquare
createRow cols = (Data.Array.replicate cols Black)

createGrid :: Int -> Int -> Crossword
createGrid w h =
  Crossword $ Data.Array.replicate h (createRow w)
