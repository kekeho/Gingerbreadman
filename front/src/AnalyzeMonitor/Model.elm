module AnalyzeMonitor.Model exposing (..)


type alias Model =
    { statusText : String
    }


modelInit : Model
modelInit =
    { statusText = "Ready"
    }
