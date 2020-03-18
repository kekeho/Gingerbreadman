module Visualizer.People exposing (..)

import Common.Data exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (..)
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


view : Visualizer.Model.Model -> Html Msg
view visualizerModel =
    div [ class "row people" ]
        (div [ class "col-12" ] [ h2 [] [ text "People" ] ]
            :: List.map personView visualizerModel.people
        )


personView : Person -> Html Msg
personView person =
    div [ class "person col-xl-3 col-4" ]
        [ div [ class "row" ]
            (List.map faceView person)
        ]


faceView : Face -> Html Msg
faceView face =
    div [ class "face col-xl-4 col-6" ]
        [ img [ src face.faceImageB64 ] []
        , p [ class "place" ] [ text face.place.name ]
        ]
