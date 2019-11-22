module Data exposing (..)

import Http
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline as P


setAllPlaces : Model -> Result Http.Error (List Place) -> Model
setAllPlaces model result =
    case result of
        Ok places ->
            { model | allPlaces = Just places }

        Err _ ->
            model



-- MODEL TYPES


type alias Model =
    { controller : ControllerModel
    , allPlaces : Maybe (List Place)
    , people : Maybe (List Person)
    }


type alias ControllerModel =
    { fromTimeString : String
    , toTimeString : String
    , places : Maybe (List Place)
    , error : Maybe ControllerError
    }


type alias ControllerError =
    { message : String
    , errorType : ControllerErrorType
    }


type ControllerErrorType
    = GroupingError


type alias Person =
    { faces : List Face
    , color : RgbColor
    }


type alias Face =
    { id : String
    , imageId : String
    , imageUrl : String
    , faceImageB64 : String
    , faceLocation : FaceLocation
    , faceEncoding : List Float
    , place : Place

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


type alias Place =
    { name : String
    , latitude : Float
    , longitude : Float
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


type alias RgbColor =
    { r : Int, g : Int, b : Int }



-- JSON DECODERS


faceLocationDecoder : Decoder FaceLocation
faceLocationDecoder =
    D.map4 FaceLocation
        (D.index 0 D.int)
        (D.index 1 D.int)
        (D.index 2 D.int)
        (D.index 3 D.int)


placeDecoder : Decoder Place
placeDecoder =
    D.map3 Place
        (D.field "name" D.string)
        (D.field "latitude" D.float)
        (D.field "longitude" D.float)


peopleDecoder : Decoder (List Person)
peopleDecoder =
    D.field "grouped_faces" (D.list personDecoder)


personDecoder : Decoder Person
personDecoder =
    D.map2 Person
        (D.field "faces" (D.list faceDecoder))
        (D.field "person_color" rgbColorDecoder)


rgbColorDecoder : Decoder RgbColor
rgbColorDecoder =
    D.map3 RgbColor
        (D.index 0 D.int)
        (D.index 1 D.int)
        (D.index 2 D.int)


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


allPlaceDecoder : Decoder (List Place)
allPlaceDecoder =
    D.map3 Place
        (D.field "name" D.string)
        (D.field "latitude" D.float)
        (D.field "longitude" D.float)
        |> D.list
