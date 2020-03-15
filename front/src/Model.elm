module Model exposing (..)

import Browser.Navigation as Nav
import Common.ErrorPanel as ErrorPanel
import Upload.Model
import Url
import Url.Parser
import Visualizer.Model



-- MODEL


type alias RootModel =
    { key : Nav.Key
    , url : Url.Url
    , route : Route
    , errorList : ErrorPanel.Model
    , visualizer : Visualizer.Model.Model
    , upload : Upload.Model.Model
    }


type Route
    = VisualizerPage
    | UploadPage
