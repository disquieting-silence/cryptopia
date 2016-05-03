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

extractKeyPress :: forall eff. KeyEvent -> Eff (dom :: DOM | eff) { target :: Node, modifier :: CrosswordSquare -> CrosswordSquare }
extractKeyPress evt = do
  let which = evt.which
  name <- getNodeName evt.target
  return { target: evt.target, modifier: noop }

processKeyPress :: forall eff. KeyEvent -> Crossword -> Eff (dom :: DOM | eff) UpdateGameState
processKeyPress evt cword = do
  extracted <- extractKeyPress evt
  apiUpdate extracted.target cword extracted.modifier

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
  getNextPosition: getNextPosition,
  load: apiLoad,
  save: apiSave,
  processKeypress: processKeyPress,
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
