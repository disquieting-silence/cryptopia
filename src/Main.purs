module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Maybe
import Data.Array
import Data.Foldable
import Math
import Data.Int

import Browser.Common
import Browser.Storage
import Core.Crossword
import Core.Ui
import Alien

data Navigation = North | East | South | West


loadFromRawFormat :: RawFormat -> CrosswordUi
loadFromRawFormat input =
  let model = Core.Crossword.parse input
  in Core.Ui.renderCrossword model

apiLoadFrom :: forall eff. RawFormat -> Eff (dom :: DOM | eff) (Maybe UpdateGameState)
apiLoadFrom raw =
  let info = loadFromRawFormat raw
  in (\i -> Just { model: Core.Crossword.parse raw, node: i, focused: Nothing}) <$> (renderNode info)

apiFailedLoad :: forall eff. String -> Eff (dom :: DOM | eff) (Maybe UpdateGameState)
apiFailedLoad name = do
  return Nothing

apiLoad :: forall eff. String -> Eff (dom :: DOM, browser :: BrowserStorage | eff) (Maybe UpdateGameState)
apiLoad name = do
  input <- getFromStorage name
  maybe (apiFailedLoad name) apiLoadFrom input.detail

apiSave :: forall eff. String -> Crossword -> Eff (browser :: BrowserStorage | eff) Unit
apiSave name cword = do
  let toSave = Core.Crossword.serialise cword
  putInStorage name toSave

readIndices :: String -> String -> Maybe { colIndex:: Int, rowIndex:: Int }
readIndices rowIndex colIndex = do
  ri <- fromString rowIndex
  ci <- fromString colIndex
  return { colIndex: ci, rowIndex: ri }


findAgain :: forall eff. Node -> { colIndex :: Int, rowIndex :: Int } -> Eff (dom :: DOM | eff) (Maybe Node)
findAgain container indices = do
  rows <- querySelectorAll container "tr"
  theRow <- pure $ (rows !! indices.rowIndex)
  cells <- maybe (pure []) (\r -> querySelectorAll r "td") theRow
  pure $ (cells !! indices.colIndex)


apiUpdate :: forall eff. Node -> Crossword -> (CrosswordSquare -> CrosswordSquare) -> Eff (dom :: DOM | eff) UpdateGameState
apiUpdate node cword modifier = do
  rowIndex <- (readAttribute node "data-row-index")
  colIndex <- (readAttribute node "data-col-index")
  let indices = readIndices rowIndex colIndex
  let updated = Data.Maybe.maybe cword (\i -> updateGrid cword i.rowIndex i.colIndex modifier) indices
  rendered <- apiRenderGrid updated
  focused <- Data.Maybe.maybe (pure Nothing) (\i -> findAgain rendered i) indices
  return { model: updated, node: rendered, focused: focused }


noop :: CrosswordSquare -> CrosswordSquare
noop sq = Black

extractKeypress :: forall eff. KeyEvent -> Eff (dom :: DOM | eff) { target :: Node, modifier :: CrosswordSquare -> CrosswordSquare }
extractKeypress evt = do
  let which = evt.which
  name <- getNodeName evt.target
  return { target: evt.target, modifier: noop }

extractKeydown :: KeyEvent -> (Maybe Navigation)
extractKeydown evt = do
  case evt.which of
    37 -> Just West
    38 -> Just North
    39 -> Just East
    40 -> Just South
    _ -> Nothing

processKeypress :: forall eff. KeyEvent -> Crossword -> Eff (dom :: DOM | eff) UpdateGameState
processKeypress evt cword = do
  extracted <- extractKeypress evt
  apiUpdate extracted.target cword extracted.modifier


getNextSquare :: forall eff. Node -> { rowIndex :: Int, colIndex :: Int } -> KeyEvent -> Bounds -> Eff (dom :: DOM | eff) (Maybe Node)
getNextSquare container indices evt bounds =
  let nextPoint = getNextPosition { x: indices.colIndex, y: indices.rowIndex } evt bounds
  in findAgain container { colIndex: nextPoint.x, rowIndex: nextPoint.y }

processKeydown :: forall eff. Node -> Crossword -> KeyEvent -> Eff (dom :: DOM | eff) (Maybe Node)
processKeydown container cword evt = do
  -- Remove duplication and abstraction breaking.

  -- What I want to do here is get the bounds (somehow) and navigate the delta and
  -- find that cell in the container, and return it

  -- So let's assume I have the bounds.
  bounds <- pure $ maybe { width : 1, height: 1 } id (getBounds cword)
  rowIndex <- (readAttribute evt.target "data-row-index")
  colIndex <- (readAttribute evt.target "data-col-index")
  let indices = readIndices rowIndex colIndex
  Data.Maybe.maybe (pure Nothing) (\i -> getNextSquare container i evt bounds) indices




renderNode :: forall eff. CrosswordUi -> Eff (dom :: DOM | eff) Node
renderNode (CrosswordUi model) = createElementsFrom model

apiCreateGrid :: Bounds -> Crossword
apiCreateGrid bounds = Core.Crossword.createGrid bounds.width bounds.height

apiRenderGrid :: forall eff. Crossword -> Eff (dom :: DOM | eff) Node
apiRenderGrid cword =
  let ui = Core.Ui.renderCrossword cword
  in renderNode ui

bridgeApi :: CryptopiaApi
bridgeApi = {
  load: apiLoad,
  save: apiSave,
  processKeypress: processKeypress,
  processKeydown: processKeydown,
  createGrid: apiCreateGrid,
  renderGrid: apiRenderGrid
}

main :: forall e. Eff (console :: CONSOLE, dom :: DOM, browser :: BrowserStorage | e) Unit
main = do
  doEverything (bridgeApi)
  putInStorage "dog" [[ "a" ]]
  log "HI"

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
