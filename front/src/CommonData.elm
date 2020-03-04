module CommonData exposing (..)

import Json.Decode as D
import Json.Decode exposing (Decoder)


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

