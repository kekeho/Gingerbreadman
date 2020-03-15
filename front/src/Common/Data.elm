module Common.Data exposing (..)

import Json.Decode as D
import Json.Decode exposing (Decoder)
import Time

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events exposing (on)



-- COMMON MODEL

type alias Place =
    { name : String
    , latitude : Float
    , longitude : Float
    }


-- COMMON VIEWS

gmTitleLogo : Html msg
gmTitleLogo =
    Html.img [ src "/static/imgs/gm_small_title.png", alt "Gingerbreadman Logo" ] []


-- COMMON FUNCTIONS

placeDecoder : Decoder Place
placeDecoder =
    D.map3 Place
        (D.field "name" D.string)
        (D.field "latitude" D.float)
        (D.field "longitude" D.float)

placesDecoder : Decoder (List Place)
placesDecoder =
    D.list placeDecoder


-- IN search
placesFilter : String -> List Place -> List Place
placesFilter keyword places =
    let
        lowerCaseKeyword = String.toLower keyword
    in
    List.map (\p -> { p | name = String.toLower p.name }) places
        |> List.filter (\p -> String.contains lowerCaseKeyword p.name)
    


-- onchange event
onChange : (String -> msg) -> Attribute msg
onChange handler =
    on "change" (D.map handler Events.targetValue)


msecToStr : Time.Posix -> String
msecToStr time =
    Time.posixToMillis time
        |> String.fromInt
