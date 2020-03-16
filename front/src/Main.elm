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
import Browser.Navigation as Nav
import Common.Data
import Common.ErrorPanel
import Common.Settings
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D exposing (Decoder)
import Model exposing (..)
import Time
import Upload.Upload
import Url
import Url.Builder
import Url.Parser
import Visualizer.Controller
import Visualizer.Visualizer



-- MAIN


main : Program () RootModel Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


init : () -> Url.Url -> Nav.Key -> ( RootModel, Cmd Msg )
init flags url key =
    ( -- Initialize model
      { key = key
      , url = url
      , route = VisualizerPage
      , errorList = []
      , visualizer =
            { controller =
                { places = []
                , selectedPlaces = []
                , placeSearchKeyword = ""
                , dateRange =
                    { since = Time.millisToPosix 0
                    , until = Time.millisToPosix 0
                    }
                }
            }
      , upload =
            { places = Nothing
            , selectedPlace = Nothing
            , selectedImages = Nothing
            , newPlace = { name = "", latitude = 0.0, longitude = 0.0 }
            , placeSearchFiltered = []
            , placeSearchInput = ""
            , uploadedIndicator = Nothing
            }
      , settings =
            { timezone = Time.utc
            , timezoneName = Time.Name "UTC"
            }
      }
      -- Command to get all places
    , Cmd.batch
        [ Nav.pushUrl key (Url.toString url)
        , Cmd.map SettingsMsg Common.Settings.getTimezoneWithZoneName

        -- , Http.get
        --     { url = Url.Builder.absolute [ "visualizer", "get_places_all" ] []
        --     , expect = Http.expectJson Visualizer.Main.GotAllPlaces Visualizer.Main.allPlaceDecoder
        --     }
        -- Init OpenLayers Map
        -- , Map.initMap "olmap"
        ]
    )



-- UDPATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | VisualizerMsg Visualizer.Visualizer.Msg
    | UploadMsg Upload.Upload.Msg
    | ErrorMsg Common.ErrorPanel.Msg
    | SettingsMsg Common.Settings.Msg


update : Msg -> RootModel -> ( RootModel, Cmd Msg )
update msg rootModel =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( rootModel, Nav.pushUrl rootModel.key (Url.toString url) )

                Browser.External href ->
                    ( rootModel, Nav.load href )

        UrlChanged url ->
            let
                onLoadCmd =
                    case Url.Parser.parse routeParser url of
                        Just UploadPage ->
                            Cmd.map UploadMsg Upload.Upload.getPlaces

                        Just VisualizerPage ->
                            Cmd.map VisualizerMsg Visualizer.Visualizer.onLoad

                        _ ->
                            Cmd.none
            in
            ( { rootModel | url = url }
            , onLoadCmd
            )

        VisualizerMsg subMsg ->
            let
                ( rootModel_, cmd ) =
                    Visualizer.Visualizer.update subMsg rootModel
            in
            ( rootModel_, Cmd.map VisualizerMsg cmd )

        UploadMsg subMsg ->
            let
                ( model_, cmd ) =
                    Upload.Upload.update subMsg rootModel
            in
            ( model_
            , Cmd.map UploadMsg cmd
            )

        ErrorMsg subMsg ->
            let
                ( model_, cmd ) =
                    Common.ErrorPanel.update subMsg rootModel.errorList
            in
            ( { rootModel | errorList = model_ }
            , Cmd.map ErrorMsg cmd
            )

        SettingsMsg subMsg ->
            let
                ( settingsModel, cmd ) =
                    Common.Settings.update subMsg rootModel.settings
            in
            ( { rootModel | settings = settingsModel }
            , Cmd.none
            )



-- VIEW


view : RootModel -> Browser.Document Msg
view rootModel =
    let
        viewPage view_ model_ msg_ =
            let
                { title, body } =
                    view_ model_
            in
            { title = "Gingerbreadman | " ++ title
            , body =
                [ navbarView rootModel
                , div [ class "app" ]
                    (List.map (Html.map msg_) body)
                , Common.ErrorPanel.view rootModel.errorList
                    |> Html.map ErrorMsg
                ]
            }
    in
    case Url.Parser.parse routeParser rootModel.url of
        Just VisualizerPage ->
            viewPage Visualizer.Visualizer.view rootModel VisualizerMsg

        Just UploadPage ->
            viewPage Upload.Upload.view rootModel UploadMsg

        Nothing ->
            notFoundView


navbarView : RootModel -> Html Msg
navbarView model =
    div [ class "navbar navbar-expand bg-dark navbar-dark" ]
        [ a [ class "navbar-brand", href "/" ]
            [ Common.Data.gmTitleLogo ]
        , div [ class "nav navbar-nav" ]
            [ a [ class "nav-item nav-link active ", href "/upload" ] [ text "Upload" ]
            ]
        ]


notFoundView : Browser.Document Msg
notFoundView =
    { title = "Gingerbreadman | 404 Error"
    , body =
        [ div []
            [ h1 [] [ text "404" ] ]
        ]
    }



-- FUNCTIONS


routeParser : Url.Parser.Parser (Route -> a) a
routeParser =
    Url.Parser.oneOf
        [ Url.Parser.map VisualizerPage Url.Parser.top
        , Url.Parser.map UploadPage (Url.Parser.s "upload")
        ]
