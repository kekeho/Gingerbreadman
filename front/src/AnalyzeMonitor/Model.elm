module AnalyzeMonitor.Model exposing (..)


type alias Model =
    { services : List ServiceModel
    }


type alias ServiceModel =
    { service : String
    , remain : Int
    , analyzing : Int
    , analyzed : Int
    }


modelInit : Model
modelInit =
    { services = []
    }
