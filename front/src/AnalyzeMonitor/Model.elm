module AnalyzeMonitor.Model exposing (..)


type alias Model =
    { services : List ServiceModel
    }



type Service
    = FaceLocation
    | FaceEncodings
    | AgePrediction
    | SexDetection



type alias ServiceModel =
    { service : Service
    , remain : Int
    , analyzing : Int
    , analyzed : Int
    }


modelInit : Model
modelInit =
    { services =
        [ ServiceModel FaceLocation 1024 500 36251
        , ServiceModel FaceEncodings 324 500 12961
        , ServiceModel AgePrediction 0 0 121512
        , ServiceModel SexDetection 0 213 52190
        ]
    }


-- FUNC

serviceToStr : Service -> String
serviceToStr service =
    case service of
        FaceLocation ->
            "face_location"
        FaceEncodings ->
            "face_encodings"
        AgePrediction ->
            "age_prediction"
        SexDetection ->
            "sex_detection"
