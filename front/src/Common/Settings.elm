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


module Common.Settings exposing (..)

import Iso8601
import Task
import Time
import Time.Extra



-- MODELINIT


modelInit : Model
modelInit =
    { timezone = Time.utc
    , timezoneName = Time.Name "UTC"
    }



-- MODEL


type alias Model =
    { timezone : Time.Zone
    , timezoneName : Time.ZoneName
    }



-- UPDATE


type Msg
    = GotTimezoneName Time.ZoneName
    | GotTimezone Time.Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotTimezoneName zonename ->
            ( { model | timezoneName = zonename }
            , Cmd.none
            )

        GotTimezone timezone ->
            ( { model | timezone = timezone }
            , Cmd.none
            )


getTimezoneWithZoneName : Cmd Msg
getTimezoneWithZoneName =
    Cmd.batch
        [ getTimeZoneName
        , getTimeZone
        ]


getTimeZoneName : Cmd Msg
getTimeZoneName =
    Task.perform GotTimezoneName Time.getZoneName


getTimeZone : Cmd Msg
getTimeZone =
    Task.perform GotTimezone Time.here



-- FUNCTIONS


timezoneNameString : Time.ZoneName -> String
timezoneNameString zonename =
    case zonename of
        Time.Name name ->
            name

        Time.Offset offset ->
            "UTC "
                ++ String.fromInt (offset // 60)
                ++ "H"


dropSecsStr : Time.Posix -> String
dropSecsStr time =
    Iso8601.fromTime time
        |> String.split ":"
        |> List.take 2
        |> List.intersperse ":"
        |> joinStrings


localDropSecsStr : Time.Zone -> Time.Posix -> String
localDropSecsStr hereZone utcTime =
    let
        offset =
            Time.Extra.toOffset hereZone utcTime
    in
    Time.posixToMillis utcTime
        |> (\t -> t + offset * 60 * 1000)
        |> Time.millisToPosix
        |> dropSecsStr


joinStrings : List String -> String
joinStrings stringList =
    case List.head stringList of
        Nothing ->
            ""

        Just string ->
            string ++ joinStrings (List.drop 1 stringList)


toUTC : Time.Zone -> Time.Posix -> Time.Posix
toUTC hereZone localTime =
    let
        offset =
            Time.Extra.toOffset hereZone localTime
    in
    Time.posixToMillis localTime
        |> (\t -> t - (offset * 60 * 1000))
        |> Time.millisToPosix
