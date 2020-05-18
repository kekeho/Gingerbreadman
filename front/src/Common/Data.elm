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


module Common.Data exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events exposing (on)
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline as P
import Time



-- COMMON MODEL


type alias Place =
    { name : String
    , latitude : Float
    , longitude : Float
    }



-- COMMON VIEWS


gmTitleLogo : Html msg
gmTitleLogo =
    Html.img [ src "/static/imgs/gm_small_title.png", alt "Gingerbreadman Logo" ] []



-- DECODER


placeDecoder : Decoder Place
placeDecoder =
    D.map3 Place
        (D.field "name" D.string)
        (D.field "latitude" D.float)
        (D.field "longitude" D.float)


placesDecoder : Decoder (List Place)
placesDecoder =
    D.list placeDecoder


datetimeDecoder : Decoder Time.Posix
datetimeDecoder =
    D.map Time.millisToPosix D.int



-- FUNCTIONS
-- IN search


placesFilter : String -> List Place -> List Place
placesFilter keyword places =
    let
        lowerCaseKeyword =
            String.toLower keyword
    in
    List.filter
        (\p -> String.contains lowerCaseKeyword (String.toLower p.name))
        places



-- onchange event


onChange : (String -> msg) -> Attribute msg
onChange handler =
    on "change" (D.map handler Events.targetValue)


msecToStr : Time.Posix -> String
msecToStr time =
    Time.posixToMillis time
        |> String.fromInt
