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
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D exposing (Decoder)
import Url.Builder
import Url.Parser
import Url

import Visualizer
import Upload


-- MAIN


main : Program () Model Msg
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


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , route : Route
    , visualizer : Visualizer.Model
    , upload : Upload.Model
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( -- Initialize model
    { key = key
    , url = url
    , route = VisualizerPage
    , visualizer =
        { test = "hoge"
        }
    , upload = 
        { places = Nothing
        , getPlacesError = Nothing
        , uploadResult = Nothing
        }
    }
      -- Command to get all places
    , Cmd.batch
        [ Nav.pushUrl key (Url.toString url)
        -- , Http.get
        --     { url = Url.Builder.absolute [ "visualizer", "get_places_all" ] []
        --     , expect = Http.expectJson Visualizer.Main.GotAllPlaces Visualizer.Main.allPlaceDecoder
        --     }

        -- Init OpenLayers Map
        -- , Map.initMap "olmap"
        ]
    )

type Route
    = VisualizerPage
    | UploadPage


-- UDPATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | VisualizerMsg Visualizer.Msg
    | UploadMsg Upload.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )
                
                Browser.External href ->
                    ( model, Nav.load href )
        
        UrlChanged url ->
            let
                onLoadCmd =
                    case Url.Parser.parse routeParser url of
                        Just UploadPage ->
                            Cmd.map UploadMsg Upload.getPlaces
                        
                        _ ->
                            Cmd.none
            in
            ( {model | url = url}
            , onLoadCmd)
        
        VisualizerMsg subMsg ->
            let
                ( model_, cmd ) =
                    Visualizer.update subMsg model.visualizer
            in                
            ({ model | visualizer = model_ }, Cmd.map VisualizerMsg cmd)
        
        UploadMsg subMsg ->
            let
                ( model_, cmd ) =
                    Upload.update subMsg model.upload
            in
            ( { model | upload = model_ }
            , Cmd.map UploadMsg cmd
            )


-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        viewPage view_ model_ msg_ =
            let
                { title, body } = view_ model_
            in
            { title = "Gingerbreadman | " ++ title
            , body = List.map (Html.map msg_) body
            }
    in
    case Url.Parser.parse routeParser model.url of
        Just VisualizerPage ->
            viewPage Visualizer.view model.visualizer VisualizerMsg
        
        Just (UploadPage) ->
            viewPage Upload.view model.upload UploadMsg
        
        Nothing ->
            notFoundView
            


notFoundView : Browser.Document Msg
notFoundView =
    { title = "Gingerbreadman | 404 Error"
    , body =
        [ div [ ]
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

