module Visualizer.People exposing (..)

import Common.Data exposing (..)
import Common.Settings exposing (localDropSecsStr)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (..)
import Time
import Visualizer.Model exposing (..)



-- UPDATE


type Msg
    = Dammy


update : Msg -> RootModel -> ( RootModel, Cmd Msg )
update msg rootModel =
    case msg of
        _ ->
            ( rootModel
            , Cmd.none
            )



-- VIEW


view : RootModel -> Html Msg
view rootModel =
    div [ class "row people" ]
        (div [ class "col-12" ] [ h2 [] [ text "People" ] ]
            :: List.map (personView rootModel.settings.timezone) rootModel.visualizer.people
        )


personView : Time.Zone -> Person -> Html Msg
personView timezone person =
    let
        sorted =
            sortWithTime person
    in
    div [ class "person col-xl-3 col-4" ]
        [ div [ class "row" ]
            (List.map (faceView timezone) sorted)
        ]


faceView : Time.Zone -> Face -> Html Msg
faceView timezone face =
    div [ class "face col-xl-4 col-6" ]
        [ img [ src face.faceImageB64, title (localDropSecsStr timezone face.datetime) ] []
        , p [ class "place" ] [ text face.place.name ]
        ]
