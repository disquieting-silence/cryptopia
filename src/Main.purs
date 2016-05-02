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

loadFromRawFormat :: RawFormat -> CrosswordUi
loadFromRawFormat input =
  let model = Core.Crossword.parse input
  in Core.Ui.renderCrossword model

apiLoadFrom :: forall eff. RawFormat -> Eff (dom :: DOM | eff) (Maybe Node)
apiLoadFrom raw =
  let info = loadFromRawFormat raw
  in Just <$> (renderNode info)

apiFailedLoad :: forall eff. String -> Eff (dom :: DOM | eff) (Maybe Node)
apiFailedLoad name = do
  return Nothing

apiLoad :: forall eff. String -> Eff (dom :: DOM, browser :: BrowserStorage | eff) (Maybe Node)
apiLoad name = do
  input <- getFromStorage name
  maybe (apiFailedLoad name) apiLoadFrom input.detail

apiSave :: forall eff. String -> Eff (browser :: BrowserStorage | eff) Unit
apiSave name = putInStorage name []

apiUpdate :: forall eff. Point -> Maybe String -> Eff (dom :: DOM | eff) Node
apiUpdate _ _ = createElement "span" [ ] ""


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
