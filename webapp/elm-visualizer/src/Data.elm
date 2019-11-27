module Data exposing (..)

import EverySet
import Http
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline as P
import List.Extra
import Time


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



{-
   Traffic per places
   example:
       { places = [Tokyo, Paris, London, Osaka, Tokyo]
       , count: 23
       }
       means, There were 23 people who started from Tokyo and
       traveled around cities Paris -> London -> Osaka and returned to Tokyo
-}


type alias Traffic =
    { places : List Place
    , count : Int
    }



-- FUNCTIONS


sortWithTime : Person -> Person
sortWithTime person =
    let
        times =
            List.map
                (\f -> { posix = Time.posixToMillis f.datetime, face = f })
                person.faces

        sortedFaces =
            List.sortBy .posix times
                |> List.map (\t -> t.face)
    in
    { person | faces = sortedFaces }



-- [Tokyo, London, London, Paris, Tokyo] -> [Tokyo, London, Paris, Tokyo]


placeHistoryNoDuplicate : List Place -> List Place
placeHistoryNoDuplicate places =
    case places of
        head :: body ->
            case body of
                next :: body_ ->
                    case head == next of
                        True ->
                            head :: placeHistoryNoDuplicate body_

                        False ->
                            head :: placeHistoryNoDuplicate body

                _ ->
                    head :: body

        _ ->
            places


getTraffic : List Person -> List Traffic
getTraffic people =
    let
        allPattern =
            List.map getTrafficPatternPerPerson people
                |> List.concat

        unique =
            EverySet.fromList allPattern
    in
    EverySet.map (getTrafficHelper allPattern) unique
        |> EverySet.toList


getTrafficHelper : List (List Place) -> List Place -> Traffic
getTrafficHelper allPattern pattern =
    let
        count =
            List.Extra.count ((==) pattern) allPattern
    in
    { places = pattern
    , count = count
    }


getTrafficPatternPerPerson : Person -> List (List Place)
getTrafficPatternPerPerson person =
    let
        places : List Place
        places =
            List.map .place person.faces
                |> placeHistoryNoDuplicate
    in
    case places of
        head :: body ->
            tHelper head body []

        _ ->
            []


tHelper : Place -> List Place -> List (List Place) -> List (List Place)
tHelper head body already =
    let
        pattern =
            trafficPatternHelper [ head ] body already
    in
    case body of
        nextHead :: nextBody ->
            trafficPatternHelper [ nextHead ] nextBody pattern

        _ ->
            pattern ++ already


trafficPatternHelper : List Place -> List Place -> List (List Place) -> List (List Place)
trafficPatternHelper head body already =
    let
        pattern =
            trafficPatternMatchHelper head body
    in
    case body of
        next :: nextBody ->
            trafficPatternHelper (head ++ [ next ]) nextBody (pattern ++ already)

        _ ->
            pattern ++ already


trafficPatternMatchHelper : List Place -> List Place -> List (List Place)
trafficPatternMatchHelper head body =
    List.map (\p -> head ++ [ p ]) body



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
        |> P.required "posix_millisec" datetimeDecoder


allPlaceDecoder : Decoder (List Place)
allPlaceDecoder =
    D.map3 Place
        (D.field "name" D.string)
        (D.field "latitude" D.float)
        (D.field "longitude" D.float)
        |> D.list


datetimeDecoder : Decoder Time.Posix
datetimeDecoder =
    D.map Time.millisToPosix D.int
