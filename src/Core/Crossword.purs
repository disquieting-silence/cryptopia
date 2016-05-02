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

findCell :: Crossword -> Int -> Int -> Maybe CrosswordSquare
findCell (Crossword model) r c = do
  row <- model !! r
  cell <- row !! c
  return cell

setCellContent :: String -> CrosswordSquare -> CrosswordSquare
setCellContent "" _ = Empty { num: Nothing }
setCellContent c sq = Full { num: Nothing, content: c }

updateCell :: Maybe String -> CrosswordSquare -> CrosswordSquare
updateCell (Nothing) sq = sq
updateCell (Just s) sq = setCellContent s sq

updateRow :: Int -> Maybe String -> Array CrosswordSquare -> Array CrosswordSquare
updateRow c s row =
  let updatedRow = Data.Array.modifyAt c (updateCell s) row
  in maybe row id updatedRow

updateGrid :: Crossword -> Int -> Int -> Maybe String -> Crossword
updateGrid (Crossword model) r c s =
  let updatedModel = Data.Array.modifyAt r (updateRow c s) model
  in Crossword $ maybe model id updatedModel
