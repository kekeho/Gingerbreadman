module Visualizer.Visualizer exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (RootModel)
import Visualizer.Controller
import Visualizer.Map
import Visualizer.Model exposing (Model)
import Visualizer.People
import Visualizer.Traffic



-- UDPATE


type Msg
    = ControllerMsg Visualizer.Controller.Msg
    | PeopleMsg Visualizer.People.Msg


update : Msg -> RootModel -> ( RootModel, Cmd Msg )
update msg rootModel =
    case msg of
        ControllerMsg subMsg ->
            let
                ( rootModel_, cmd_ ) =
                    Visualizer.Controller.update subMsg rootModel

                cmd =
                    Cmd.map ControllerMsg cmd_
            in
            ( rootModel_, cmd )

        PeopleMsg subMsg ->
            let
                ( rootModel_, cmd_ ) =
                    Visualizer.People.update subMsg rootModel

                cmd =
                    Cmd.map PeopleMsg cmd_
            in
            ( rootModel_, cmd )



-- VIEW


view : RootModel -> Browser.Document Msg
view rootModel =
    { title = "Visualizer"
    , body =
        [ div [ class "visualizer" ]
            [ div [ class "map-controller-row" ]
                [ Visualizer.Map.mapView "map"
                , Visualizer.Controller.view rootModel
                    |> Html.map ControllerMsg
                ]
            , div [ class "row" ]
                -- People, Traffic...
                [ Visualizer.People.view rootModel
                    |> Html.map PeopleMsg
                , Visualizer.Traffic.view rootModel.visualizer
                ]
            ]

        -- MODAL
        , Visualizer.Controller.viewControllerModal rootModel
            |> Html.map ControllerMsg
        ]
    }



-- FUNCTIONS


onLoad : Cmd Msg
onLoad =
    Cmd.batch
        [ Cmd.map ControllerMsg Visualizer.Controller.getPlaces
        , Visualizer.Map.initMap "map"
        ]
