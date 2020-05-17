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
    div [ class "people", id "people" ]
        [ h2 [ class "title" ] [ text "People" ] 
        , div [ class "people-container" ]
            (List.map (personView rootModel.settings.timezone) rootModel.visualizer.people)
        ]


personView : Time.Zone -> Person -> Html Msg
personView timezone person =
    let
        sorted =
            sortWithTime person
    in
    div [ class "person-container" ]
        (List.map (faceView timezone) sorted)


faceView : Time.Zone -> Face -> Html Msg
faceView timezone face =
    div [ class "face" ]
        [ img
            [ src face.faceImageB64
            , title (face.place.name ++ " " ++ sexString face.sex ++ " " ++ localDropSecsStr timezone face.datetime) ] []
        ]

sexString : Sex -> String
sexString sex =
    case sex of
        Male ->
            "Male"
        Female ->
            "Female"
        NotKnown ->
            "Not Known"
