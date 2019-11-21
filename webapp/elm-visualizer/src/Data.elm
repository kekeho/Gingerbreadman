module Data exposing
    ( ControllerModel
    , Emotion
    , FaceLocation
    , Gender
    , Model
    , Person
    , Place
    , allPlaceDecoder
    , setAllPlaces
    )

import Http
import Json.Decode as D exposing (Decoder)


setAllPlaces : Model -> Result Http.Error (List Place) -> Model
setAllPlaces model result =
    case result of
        Ok places ->
            { model | allPlaces = Just places }

        Err _ ->
            model


allPlaceDecoder : Decoder (List Place)
allPlaceDecoder =
    D.map3 Place
        (D.field "name" D.string)
        (D.field "latitude" D.float)
        (D.field "longitude" D.float)
        |> D.list



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
    }


type alias Person =
    { id : String
    , imageId : String
    , imageUrl : String
    , faceLocation : FaceLocation
    , faceEncoding : List Float
    , place : Place
    , gender : Maybe Gender
    , age : Maybe Float
    , emotion : Maybe Emotion
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
