module Visualizer.Model exposing (..)

import Common.Data exposing (Place, placeDecoder, datetimeDecoder)
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline as P
import Time


-- MODEL INIT

modelInit : Model
modelInit =
    { controller = controllerModelInit
    , people = peopleInit
    }

controllerModelInit : ControllerModel
controllerModelInit =
    { places = []
    , selectedPlaces = []
    , placeSearchKeyword = ""
    , dateRange =
        { since = Time.millisToPosix 0
        , until = Time.millisToPosix 0
        }
    }

peopleInit : List Person
peopleInit =
    []


-- MODELS


type alias Model =
    { controller : ControllerModel
    , people : List Person
    }


type alias ControllerModel =
    { places : List Place
    , selectedPlaces : List Place
    , placeSearchKeyword : String
    , dateRange : DateRange
    }


type alias Person =
    List Face


type alias Face =
    { id : String
    , imageId : String
    , imageUrl : String
    , faceImageB64 : String
    , faceLocation : FaceLocation
    , faceEncoding : List Float
    , place : Place
    , datetime : Time.Posix

    -- , gender : Maybe Gender
    -- , age : Maybe Float
    -- , emotion : Maybe Emotion
    }


type alias FaceLocation =
    { x : Int
    , y : Int
    , w : Int
    , h : Int
    }


type Gender
    = NotKnown
    | Male
    | Female


type Emotion
    = Smile
    | Anger
    | Contempt
    | Disgust
    | Fear
    | Happiness
    | Neutral
    | Sadness
    | Surprise


type alias Traffic =
    { places : List Place
    , count : Int
    }


type alias DateRange =
    { since : Time.Posix
    , until : Time.Posix
    }



-- FUNCTIONS


sortWithTime : Person -> Person
sortWithTime person =
    let
        times =
            List.map
                (\f -> { posix = Time.posixToMillis f.datetime, face = f })
                person

        sortedFaces =
            List.sortBy .posix times
                |> List.map (\t -> t.face)
    in
    sortedFaces



-- JSON DECODERS

peopleDecoder : Decoder (List Person)
peopleDecoder =
    D.field "grouped_faces" (D.list personDecoder)


personDecoder : Decoder Person
personDecoder =
    D.list faceDecoder


faceDecoder : Decoder Face
faceDecoder =
    D.succeed Face
        |> P.required "id" D.string
        |> P.required "image_id" D.string
        |> P.required "image_url" D.string
        |> P.required "face_image" D.string
        |> P.required "face_location" faceLocationDecoder
        |> P.required "face_encoding" (D.list D.float)
        |> P.required "place" placeDecoder
        |> P.required "posix_millisec" datetimeDecoder


faceLocationDecoder : Decoder FaceLocation
faceLocationDecoder =
    D.map4 FaceLocation
        (D.index 0 D.int)
        (D.index 1 D.int)
        (D.index 2 D.int)
        (D.index 3 D.int)
