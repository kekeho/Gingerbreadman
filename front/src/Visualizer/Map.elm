port module Visualizer.Map exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

import Model exposing (..)


-- update

type Msg
    = Initialized


update : Msg -> RootModel -> ( RootModel, Cmd Msg )
update msg rootModel =
    case msg of
        Initialized ->
             ( rootModel, Cmd.none )


-- ports

port initMap : String -> Cmd msg



-- VIEW


mapView : String -> Html msg
mapView mapId =
    div [ id mapId, class "map" ] []
