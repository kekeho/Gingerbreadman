port module Map exposing (..)

import Data exposing (Model)
import Html exposing (..)
import Html.Attributes exposing (..)


port initMap : String -> Cmd msg



-- VIEW


view : String -> Html msg
view mapId =
    div [ id mapId ] []
