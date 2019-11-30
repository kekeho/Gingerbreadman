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

module SidePanel exposing (Msg, update, view)

import Controller
import Data exposing (Model)
import Html exposing (..)
import Html.Attributes exposing (..)
import People



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "sidepanel" ]
        [ People.view model
        , Html.map ControllerMsg (Controller.view model)
        ]



-- UPDATE


type Msg
    = ControllerMsg Controller.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ControllerMsg subMsg ->
            let
                ( model_, cmd ) =
                    Controller.update subMsg model
            in
            ( model_, Cmd.map ControllerMsg cmd )
