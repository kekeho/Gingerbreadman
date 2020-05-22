--  Copyright (C) 2020 Hiroki Takemura (kekeho)
--
--  This file is part of Gingerbreadman.
--
-- Gingerbreadman is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- Gingerbreadman is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Gingerbreadman.  If not, see <http://www.gnu.org/licenses/>.


module Visualizer.Visualizer exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (RootModel)
import TypedSvg exposing (svg)
import TypedSvg.Attributes exposing (viewBox)
import Visualizer.Controller
import Visualizer.Graph
import Visualizer.Map
import Visualizer.Model exposing (Model)
import Visualizer.People
import Visualizer.Traffic



-- UDPATE


type Msg
    = ControllerMsg Visualizer.Controller.Msg
    | PeopleMsg Visualizer.People.Msg
    | GraphMsg Visualizer.Graph.Msg


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

        GraphMsg subMsg ->
            let
                ( rootModel_, cmd_ ) =
                    Visualizer.Graph.update subMsg rootModel

                cmd =
                    Cmd.map GraphMsg cmd_
            in
            ( rootModel_, cmd )



-- VIEW


view : RootModel -> Browser.Document Msg
view rootModel =
    { title = "Visualizer"
    , body =
        [ div [ class "visualizer horizonal-container" ]
            [ div [ class "map-controller-row" ]
                [ Visualizer.Controller.view rootModel
                    |> Html.map ControllerMsg
                , Visualizer.Map.mapView "map"
                ]
            , Visualizer.Graph.view rootModel
                |> Html.map GraphMsg
            , Visualizer.People.view rootModel
                |> Html.map PeopleMsg
            , Visualizer.Traffic.view rootModel.visualizer
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
