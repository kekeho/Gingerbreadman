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


module People exposing (..)

import Data exposing (Model, Person)
import Html exposing (..)
import Html.Attributes exposing (..)



-- VIEW


view : Model -> Html msg
view model =
    div [ class "row" ]
        [ div [ class "col-12" ]
            [ h1 [] [ text "People" ] ]
        , div [ class "col-12" ]
            [ viewPersonRow model ]
        , div [ class "col-12" ]
            [ viewTrafficCount model ]
        ]


viewPersonRow : Model -> Html msg
viewPersonRow model =
    div [ class "row people-row" ]
        (case model.people of
            Just personList ->
                List.map viewPerson personList

            Nothing ->
                []
        )


viewPerson : Person -> Html msg
viewPerson person =
    let
        imgs =
            List.map
                (\f ->
                    div [ class "col-4 face-col" ]
                        [ imageWithBase64 f.faceImageB64 "face-img"
                        , text f.place.name
                        ]
                )
                person.faces
    in
    div [ class "col-4", style "background-color" (rgbColorToCssString person.color) ]
        [ div [ class "row face-row" ] imgs
        , div [ class "row" ]
            [ placesHistoryString person ]
        ]


viewTrafficCount : Model -> Html msg
viewTrafficCount model =
    let
        traffics =
            case model.people of
                Just p ->
                    Just
                        (Data.getTraffic p
                            |> Data.trafficSortWithCount
                        )

                Nothing ->
                    Nothing
    in
    case traffics of
        Just t ->
            div []
                (List.map trafficString t
                    |> List.map (\s -> div [] [ text s ])
                )

        Nothing ->
            div []
                [ text "" ]


trafficString : Data.Traffic -> String
trafficString traffic =
    let
        places =
            traffic.places

        head =
            List.head places

        body =
            List.drop 1 places
                |> List.map .name
    in
    case head of
        Just h ->
            h.name ++ List.foldl (\n p -> p ++ " -> " ++ n) "" body ++ ": " ++ String.fromInt traffic.count

        Nothing ->
            ""


placesHistoryString : Person -> Html msg
placesHistoryString person =
    let
        faces =
            person.faces

        places =
            List.map (\f -> f.place) faces
                |> Data.placeHistoryNoDuplicate

        head =
            List.head places

        body =
            List.drop 1 places
                |> List.map (\p -> p.name)
    in
    case head of
        Just h ->
            text (h.name ++ List.foldl (\n p -> p ++ " -> " ++ n) "" body)

        Nothing ->
            text "No history"


rgbColorToCssString : Data.RgbColor -> String
rgbColorToCssString color =
    "rgb("
        ++ String.fromInt color.r
        ++ ", "
        ++ String.fromInt color.g
        ++ ", "
        ++ String.fromInt color.b
        ++ ")"


imageWithBase64 : String -> String -> Html msg
imageWithBase64 b64 className =
    img [ src b64, class className ] []
