module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Data.Maybe
import Data.Array
import Data.Foldable

import Browser.Common
import Browser.Storage
import Core.Crossword
import Core.Ui
import Alien

type UpdateGameState = { model :: Crossword, node :: Node }

loadFromRawFormat :: RawFormat -> CrosswordUi
loadFromRawFormat input =
  let model = Core.Crossword.parse input
  in Core.Ui.renderCrossword model

apiLoadFrom :: forall eff. RawFormat -> Eff (dom :: DOM | eff) (Maybe UpdateGameState)
apiLoadFrom raw =
  let info = loadFromRawFormat raw
  in (\i -> Just { model: Core.Crossword.parse raw, node: i}) <$> (renderNode info)

apiFailedLoad :: forall eff. String -> Eff (dom :: DOM | eff) (Maybe UpdateGameState)
apiFailedLoad name = do
  return Nothing

apiLoad :: forall eff. String -> Eff (dom :: DOM, browser :: BrowserStorage | eff) (Maybe { model:: Crossword, node:: Node })
apiLoad name = do
  input <- getFromStorage name
  maybe (apiFailedLoad name) apiLoadFrom input.detail

apiSave :: forall eff. String -> Crossword -> Eff (browser :: BrowserStorage | eff) Unit
apiSave name cword = do
  let toSave = Core.Crossword.serialise cword
  putInStorage name toSave

apiUpdate :: forall eff. Node -> Crossword -> Maybe String -> Eff (dom :: DOM | eff) UpdateGameState
apiUpdate node cword _ = do
  _ <- createElement "span" [] ""
  let same = { node: node, model: cword }
  return same


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
  update: apiUpdate,
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
