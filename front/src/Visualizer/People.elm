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
    div [ class "people column", id "people" ]
        [ h2 [ class "title" ] [ text "People" ] 
        , div [ class "people-container depression-container" ]
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
            , title (face.place.name ++ " " ++ sexString face.sex ++ " " ++ ageString face.age ++ " " ++ localDropSecsStr timezone face.datetime) ] []
        ]



-- FUNCTIONS


sexString : Sex -> String
sexString sex =
    case sex of
        Male ->
            "Male"
        Female ->
            "Female"
        NotKnown ->
            "Not Known"


ageString : Maybe Float -> String
ageString age =
    case age of
        Nothing ->
            ""
        Just val ->
            String.fromFloat val
