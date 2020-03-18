module Visualizer.Controller exposing (..)

import Common.Data exposing (..)
import Common.ErrorPanel
import Common.Settings
import Debug
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Iso8601
import Model exposing (RootModel)
import Time
import Url.Builder
import Visualizer.Model exposing (..)


type Msg
    = GotPlace (Result Http.Error (List Place))
    | SelectPlace String
    | DelSelectedPlace String
    | PlaceSearchInput String
    | GotSinceTime String
    | GotUntilTime String
    | Analyze
    | Analyzed (Result Http.Error (List Visualizer.Model.Person))
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

        GotSinceTime iso8601Str ->
            let
                normalized =
                    iso8601Str ++ ":00"

                dateRange =
                    controllerModel.dateRange
            in
            case Iso8601.toTime normalized |> Debug.log "debug" of
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

        GotUntilTime iso8601Str ->
            let
                normalized =
                    iso8601Str ++ ":00"

                dateRange =
                    controllerModel.dateRange
            in
            case Iso8601.toTime normalized |> Debug.log "debug" of
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
            analyze rootModel

        Analyzed result ->
            case result of
                Err error ->
                    ( { rootModel | errorList = { error = Common.ErrorPanel.HttpError error, str = "Analyzing Failed" } :: errorList }
                    , Cmd.none
                    )

                Ok people ->
                    ( { rootModel | visualizer = { visualizerModel | people = people } }
                    , Cmd.none
                    )

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
    div [ class "row controller" ]
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
            ]
        ]


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
                , value (Common.Settings.localDropSecsStr hereTimeZone controllerModel.dateRange.since)
                , onChange GotSinceTime
                ]
                []
            ]
        , div [ class "form-group" ]
            [ label [] [ text "until" ]
            , input
                [ type_ "datetime-local"
                , value (Common.Settings.localDropSecsStr hereTimeZone controllerModel.dateRange.until)
                , onChange GotUntilTime
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
