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


module Common.ErrorPanel exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http



-- MODEL


type Error
    = HttpError Http.Error
    | OnlyStr


type alias ErrorModel =
    { error : Error
    , str : String
    }


type alias Model =
    List ErrorModel



-- UPDATE


type Msg
    = AddError ErrorModel
    | DelError Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AddError error ->
            ( error :: model
            , Cmd.none
            )

        DelError index ->
            let
                newList =
                    List.filter (\( idx, err ) -> idx /= index) (List.indexedMap Tuple.pair model)
                        |> List.map (\( idx, err ) -> err)
            in
            ( newList
            , Cmd.none
            )



-- VIEW


view : List ErrorModel -> Html Msg
view errorList =
    div [ class "errorPanel" ]
        [ div [ class "errorList" ]
            (List.indexedMap Tuple.pair errorList
                |> List.map errorBoxView
            )
        ]


errorBoxView : ( Int, ErrorModel ) -> Html Msg
errorBoxView ( index, error ) =
    div [ class "errorBox row" ]
        [ div [ class "title col-10" ]
            [ text error.str ]
        , div [ class "delButton col-2", onClick (DelError index) ]
            [ text "✕" ]
        ]
