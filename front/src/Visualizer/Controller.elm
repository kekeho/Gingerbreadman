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


module Visualizer.Controller exposing (..)

import Common.Data exposing (..)
import Common.ErrorPanel
import Common.Settings
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Iso8601
import Model exposing (RootModel)
import Time
import Url.Builder
import Visualizer.Map as Map
import Visualizer.Model exposing (..)
import Visualizer.Traffic


type Msg
    = GotPlace (Result Http.Error (List Place))
    | SelectPlace String
    | DelSelectedPlace String
    | PlaceSearchInput String
    | GotSinceTime String
    | GotUntilTime String
    | ValidSinceTime String
    | ValidUntilTime String
    | Analyze
    | Analyzed (Result Http.Error (List Visualizer.Model.Person))
    | ChangeModalState Bool
    | MapMsg Map.Msg
    | ErrorMsg Common.ErrorPanel.Msg


update : Msg -> RootModel -> ( RootModel, Cmd Msg )
update msg rootModel =
    let
        visualizerModel =
            rootModel.visualizer

        controllerModel =
            visualizerModel.controller

        errorList =
            rootModel.errorList
    in
    case msg of
        GotPlace result ->
            case result of
                Ok places ->
                    ( { rootModel
                        | visualizer =
                            { visualizerModel
                                | controller =
                                    { controllerModel | places = places }
                            }
                      }
                    , Cmd.none
                    )

                Err error ->
                    let
                        ( newRootModel, cmd ) =
                            update (ErrorMsg (Common.ErrorPanel.AddError { error = Common.ErrorPanel.HttpError error, str = "Failed to load location tags" })) rootModel

                        newVisualizierModel =
                            newRootModel.visualizer

                        newControllerModel =
                            newVisualizierModel.controller
                    in
                    ( { newRootModel
                        | visualizer =
                            { newVisualizierModel
                                | controller =
                                    { newControllerModel | places = [] }
                            }
                      }
                    , cmd
                    )

        SelectPlace placeName ->
            let
                maybePlace : Maybe Place
                maybePlace =
                    List.filter (\p -> p.name == placeName) controllerModel.places
                        |> List.head
            in
            case maybePlace of
                Just place ->
                    if List.member place controllerModel.selectedPlaces then
                        ( rootModel, Cmd.none )

                    else
                        ( { rootModel | visualizer = { visualizerModel | controller = { controllerModel | selectedPlaces = controllerModel.selectedPlaces ++ [ place ] } } }
                        , Cmd.none
                        )

                Nothing ->
                    -- This error never happens
                    ( rootModel, Cmd.none )

        DelSelectedPlace placeName ->
            ( { rootModel | visualizer = { visualizerModel | controller = { controllerModel | selectedPlaces = List.filter (\p -> p.name /= placeName) controllerModel.selectedPlaces } } }
            , Cmd.none
            )

        PlaceSearchInput keyword ->
            ( { rootModel | visualizer = { visualizerModel | controller = { controllerModel | placeSearchKeyword = keyword } } }
            , Cmd.none
            )

        GotSinceTime str ->
            let
                inputDateRange =
                    controllerModel.inputDateRange
            in
            ( { rootModel
                | visualizer =
                    { visualizerModel
                        | controller =
                            { controllerModel
                                | inputDateRange = { inputDateRange | since = str }
                            }
                    }
              }
            , Cmd.none
            )

        GotUntilTime str ->
            let
                inputDateRange =
                    controllerModel.inputDateRange
            in
            ( { rootModel
                | visualizer =
                    { visualizerModel
                        | controller =
                            { controllerModel
                                | inputDateRange = { inputDateRange | until = str }
                            }
                    }
              }
            , Cmd.none
            )

        ValidSinceTime iso8601Str ->
            let
                normalized =
                    iso8601Str ++ ":00"

                dateRange =
                    controllerModel.dateRange
            in
            case Iso8601.toTime normalized of
                Ok localTime ->
                    ( { rootModel
                        | visualizer =
                            { visualizerModel
                                | controller =
                                    { controllerModel | dateRange = { dateRange | since = Common.Settings.toUTC rootModel.settings.timezone localTime } }
                            }
                      }
                    , Cmd.none
                    )

                Err error ->
                    let
                        ( newRootModel, cmd ) =
                            update (ErrorMsg (Common.ErrorPanel.AddError { error = Common.ErrorPanel.OnlyStr, str = "Format of since time is invalid" })) rootModel
                    in
                    ( newRootModel
                    , cmd
                    )

        ValidUntilTime iso8601Str ->
            let
                normalized =
                    iso8601Str ++ ":00"

                dateRange =
                    controllerModel.dateRange
            in
            case Iso8601.toTime normalized of
                Ok localTime ->
                    ( { rootModel
                        | visualizer =
                            { visualizerModel
                                | controller =
                                    { controllerModel | dateRange = { dateRange | until = Common.Settings.toUTC rootModel.settings.timezone localTime } }
                            }
                      }
                    , Cmd.none
                    )

                Err error ->
                    let
                        ( newRootModel, cmd ) =
                            update (ErrorMsg (Common.ErrorPanel.AddError { error = Common.ErrorPanel.OnlyStr, str = "Format of until time is invalid" })) rootModel
                    in
                    ( newRootModel
                    , cmd
                    )

        Analyze ->
            let
                ( model_, cmd_ ) =
                    update (ChangeModalState False) rootModel
            in
            analyze model_

        Analyzed result ->
            case result of
                Err error ->
                    ( { rootModel | errorList = { error = Common.ErrorPanel.HttpError error, str = "Analyzing Failed" } :: errorList }
                    , Cmd.none
                    )

                Ok people ->
                    let
                        trafficCount =
                            Visualizer.Traffic.f people

                        newController =
                            { controllerModel | resultDateRange = controllerModel.dateRange, resultPlaces = controllerModel.selectedPlaces }

                        newRootModel =
                            { rootModel | visualizer = { visualizerModel | controller = newController, people = people, traffic = trafficCount } }

                        ( newRootModel_, cmd_ ) =
                            Map.update Map.Update newRootModel
                    in
                    ( newRootModel_
                    , Cmd.map MapMsg cmd_
                    )

        ChangeModalState state ->
            ( { rootModel | visualizer = { visualizerModel | controller = { controllerModel | modalState = state } } }
            , Cmd.none
            )

        MapMsg subMsg ->
            let
                ( rootModel_, cmd_ ) =
                    Map.update subMsg rootModel
            in
            ( rootModel_, Cmd.map MapMsg cmd_ )

        ErrorMsg subMsg ->
            let
                ( errorPanelModel, cmd ) =
                    Common.ErrorPanel.update subMsg rootModel.errorList
            in
            ( { rootModel | errorList = errorPanelModel }
            , Cmd.map ErrorMsg cmd
            )


view : RootModel -> Html Msg
view rootModel =
    div [ class "controller" ]
        [ h2 [ class "title" ] [ text "Controller" ]
        , div [ class "col-12" ]
            [ viewControllerState rootModel
            , button
                [ class "btn btn-dark", onClick (ChangeModalState True) ]
                [ text "Change" ]
            ]
        ]


viewControllerState : RootModel -> Html Msg
viewControllerState rootModel =
    let
        controllerModel =
            rootModel.visualizer.controller

        since =
            Common.Settings.localDropSecsStr rootModel.settings.timezone controllerModel.resultDateRange.since

        until =
            Common.Settings.localDropSecsStr rootModel.settings.timezone controllerModel.resultDateRange.until

        timezone =
            case rootModel.settings.timezoneName of
                Time.Name tzname ->
                    tzname

                Time.Offset integer ->
                    "UTC" ++ String.fromInt integer

        places =
            List.map .name controllerModel.resultPlaces
                |> String.join ", "
    in
    div [ class "controller-state" ]
        [ p [ class "date " ]
            [ text ("date : " ++ since ++ " ~ " ++ until ++ " (" ++ timezone ++ ")") ]
        , p [ class "place" ]
            [ text ("places : " ++ places) ]
        ]


viewControllerModal : RootModel -> Html Msg
viewControllerModal rootModel =
    if rootModel.visualizer.controller.modalState then
        div [ class "container gb-modal" ]
            [ div [ class "row controller" ]
                [ div [ class "col-12" ]
                    [ h2 [] [ text "Controller" ] ]
                , div [ class "col-6" ]
                    [ dateSelectorView rootModel ]
                , div [ class "col-6" ]
                    [ placesView rootModel.visualizer.controller ]
                , div [ class "col-12" ]
                    [ button
                        [ class "btn btn-dark", onClick Analyze ]
                        [ text "Analyze" ]
                    , button [ class "btn", onClick (ChangeModalState False) ]
                        [ text "Close" ]
                    ]
                ]
            ]

    else
        div [] []


placesView : ControllerModel -> Html Msg
placesView controllerModel =
    div [ class "places" ]
        [ div [ class "row" ]
            [ div [ class "col-12" ]
                [ selectedPlacesView controllerModel
                , searchView controllerModel
                , allPlacesList controllerModel
                ]
            ]
        ]


selectedPlacesView : ControllerModel -> Html Msg
selectedPlacesView controllerModel =
    div [ class "selected" ]
        (List.map selectedPlaceBox controllerModel.selectedPlaces)


selectedPlaceBox : Place -> Html Msg
selectedPlaceBox place =
    div [ class "selected-place-box", onClick (DelSelectedPlace place.name) ]
        [ text place.name ]


searchView : ControllerModel -> Html Msg
searchView controllerModel =
    div [ class "search" ]
        [ input
            [ type_ "text", onInput PlaceSearchInput, value controllerModel.placeSearchKeyword, placeholder "Search Places" ]
            []
        ]


allPlacesList : ControllerModel -> Html Msg
allPlacesList controllerModel =
    ul [ class "all-places" ]
        (placesFilter controllerModel.placeSearchKeyword controllerModel.places
            |> List.map (\p -> li [ onClick (SelectPlace p.name) ] [ text p.name ])
        )


dateSelectorView : RootModel -> Html Msg
dateSelectorView rootModel =
    let
        controllerModel =
            rootModel.visualizer.controller

        hereTimeZone =
            rootModel.settings.timezone
    in
    div [ class "date-selector form" ]
        [ div [ class "form-group" ]
            [ label [] [ text "since" ]
            , input
                [ type_ "datetime-local"
                , value controllerModel.inputDateRange.since
                , onInput GotSinceTime
                , onChange ValidSinceTime
                ]
                []
            ]
        , div [ class "form-group" ]
            [ label [] [ text "until" ]
            , input
                [ type_ "datetime-local"
                , value controllerModel.inputDateRange.until
                , onInput GotUntilTime
                , onChange ValidUntilTime
                ]
                []
            ]
        , div [ class "timezone-info" ]
            [ text
                ("timezone: "
                    ++ Common.Settings.timezoneNameString rootModel.settings.timezoneName
                )
            ]
        ]



-- CMD


getPlaces : Cmd Msg
getPlaces =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Accept" "application/json"
            ]
        , url = "/api/db/get_places_all/"
        , expect = Http.expectJson GotPlace placesDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }


analyze : RootModel -> ( RootModel, Cmd Msg )
analyze rootModel =
    let
        errorList =
            rootModel.errorList

        controllerModel =
            rootModel.visualizer.controller

        path =
            Url.Builder.absolute [ "api", "analyze", "grouping" ]
    in
    case groupingQuery controllerModel of
        Nothing ->
            ( { rootModel | errorList = { error = Common.ErrorPanel.OnlyStr, str = "Please select places" } :: errorList }
            , Cmd.none
            )

        Just query ->
            ( rootModel
            , Http.request
                { method = "GET"
                , headers =
                    [ Http.header "Accept" "application/json"
                    ]
                , url = path query
                , expect = Http.expectJson Analyzed Visualizer.Model.peopleDecoder
                , body = Http.emptyBody
                , timeout = Nothing
                , tracker = Nothing
                }
            )


groupingQuery : ControllerModel -> Maybe (List Url.Builder.QueryParameter)
groupingQuery controllerModel =
    let
        timeQuery =
            [ Url.Builder.string "datetime-from" (Common.Settings.dropSecsStr controllerModel.dateRange.since)
            , Url.Builder.string "datetime-to" (Common.Settings.dropSecsStr controllerModel.dateRange.until)
            ]
    in
    if List.isEmpty controllerModel.selectedPlaces then
        Nothing

    else
        Just
            (timeQuery
                ++ List.map (\p -> Url.Builder.string "places" p.name) controllerModel.selectedPlaces
            )
