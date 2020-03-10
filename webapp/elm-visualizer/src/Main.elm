-- Copyright (C) 2019 Hiroki Takemura (kekeho)
--
-- This file is part of Gingerbreadman.
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
-- along with Gingerbreadman.  If not, see <http:--www.gnu.org/licenses/>.


module Main exposing (main)

import Browser
import Controller
import Data exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D exposing (Decoder)
import Map
import SidePanel
import Url.Builder



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


init : () -> ( Model, Cmd Msg )
init _ =
    ( -- Initialize model
      { controller =
            { fromTimeString = "1900-01-01T00:00"
            , toTimeString = "2100-12-31T00:00"
            , places = Nothing
            , error = Nothing
            }
      , allPlaces = Nothing
      , people = Nothing
      }
      -- Command to get all places
    , Cmd.batch
        [ Http.get
            { url = Url.Builder.absolute [ "visualizer", "get_places_all" ] []
            , expect = Http.expectJson GotAllPlaces allPlaceDecoder
            }

        -- Init OpenLayers Map
        , Map.initMap "olmap"
        ]
    )



-- UDPATE


type Msg
    = SidePanelMsg SidePanel.Msg
    | GotAllPlaces (Result Http.Error (List Place))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SidePanelMsg subMsg ->
            let
                ( model_, cmd ) =
                    SidePanel.update subMsg model
            in
            ( model_, Cmd.map SidePanelMsg cmd )

        GotAllPlaces result ->
            ( setAllPlaces model result, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container maincontainer" ]
        [ div [ class "row mainrow" ]
            [ div [ class "col-6" ]
                [ Map.view "olmap" ]
            , div [ class "col-6 sidepanel-root-col" ]
                [ Html.map SidePanelMsg (SidePanel.view model) ]
            ]
        ]
