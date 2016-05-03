module Core.Crossword where

import Data.Maybe
import Data.Array
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

updateRow :: Int -> (CrosswordSquare -> CrosswordSquare)-> Array CrosswordSquare -> Array CrosswordSquare
updateRow c modifier row =
  let updatedRow = Data.Array.modifyAt c modifier row
  in maybe row id updatedRow

updateGrid :: Crossword -> Int -> Int -> (CrosswordSquare -> CrosswordSquare) -> Crossword
updateGrid (Crossword model) r c modifier =
  let updatedModel = Data.Array.modifyAt r (updateRow c modifier) model
  in Crossword $ maybe model id updatedModel

getBounds :: Crossword -> Maybe { width :: Int, height :: Int }
getBounds (Crossword model) = do
  numRows <- pure (length model)
  numColumns <- length <$> (model !! 0)
  return { width: numColumns, height: numRows }
