module Common.Data exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events exposing (on)
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline as P
import Time



-- COMMON MODEL


type alias Place =
    { name : String
    , latitude : Float
    , longitude : Float
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
    }


type alias FaceLocation =
    { x : Int
    , y : Int
    , w : Int
    , h : Int
    }



-- COMMON VIEWS


gmTitleLogo : Html msg
gmTitleLogo =
    Html.img [ src "/static/imgs/gm_small_title.png", alt "Gingerbreadman Logo" ] []



-- DECODER


placeDecoder : Decoder Place
placeDecoder =
    D.map3 Place
        (D.field "name" D.string)
        (D.field "latitude" D.float)
        (D.field "longitude" D.float)


placesDecoder : Decoder (List Place)
placesDecoder =
    D.list placeDecoder


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


datetimeDecoder : Decoder Time.Posix
datetimeDecoder =
    D.map Time.millisToPosix D.int



-- FUNCTIONS
-- IN search


placesFilter : String -> List Place -> List Place
placesFilter keyword places =
    let
        lowerCaseKeyword =
            String.toLower keyword
    in
    List.filter
        (\p -> String.contains lowerCaseKeyword (String.toLower p.name))
        places



-- onchange event


onChange : (String -> msg) -> Attribute msg
onChange handler =
    on "change" (D.map handler Events.targetValue)


msecToStr : Time.Posix -> String
msecToStr time =
    Time.posixToMillis time
        |> String.fromInt
