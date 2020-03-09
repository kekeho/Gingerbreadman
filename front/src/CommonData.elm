module CommonData exposing (..)

import Json.Decode as D
import Json.Decode exposing (Decoder)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events exposing (on)



-- COMMON MODEL

type alias Place =
    { name : String
    , latitude : Float
    , longitude : Float
    }



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


-- onchange event
onChange : (String -> msg) -> Attribute msg
onChange handler =
    on "change" (D.map handler Events.targetValue)
