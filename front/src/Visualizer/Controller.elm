module Visualizer.Controller exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http

import Model exposing (RootModel)
import Visualizer.Model exposing (..)
import Common.Data exposing (..)
import Common.ErrorPanel



type Msg
    = GotPlace (Result Http.Error (List Place))
    | SelectPlace String
    | DelSelectedPlace String
    | PlaceSearchInput String
    | ErrorMsg Common.ErrorPanel.Msg


update : Msg -> RootModel -> ( RootModel, Cmd Msg )
update msg rootModel =
    let
        visualizerModel =
            rootModel.visualizer
        controllerModel =
            visualizerModel.controller
    in
    case msg of
        GotPlace result ->
            case result of
                Ok places ->
                    ( { rootModel |
                            visualizer =
                                { visualizerModel |
                                    controller =
                                        { controllerModel | places = places }
                                }
                      }
                    
                    , Cmd.none )
                Err error ->
                    let
                        ( newRootModel, cmd ) =
                            update (ErrorMsg (Common.ErrorPanel.AddError { error = Common.ErrorPanel.HttpError error, str = "Failed to load location tags"})) rootModel
                        newVisualizierModel = newRootModel.visualizer
                        newControllerModel = newVisualizierModel.controller

                    in
                    ( { newRootModel | 
                            visualizer =
                                { newVisualizierModel |
                                    controller = 
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
                    if List.member place controllerModel.selectedPlaces
                        then
                            ( rootModel, Cmd.none )                    
                        else
                            ( { rootModel | visualizer = { visualizerModel | controller = {controllerModel | selectedPlaces = controllerModel.selectedPlaces ++ [ place ] }}}
                            , Cmd.none
                            )
                Nothing ->
                    -- This error never happens
                    ( rootModel, Cmd.none )
        
        
        DelSelectedPlace placeName ->
            ( { rootModel | visualizer = { visualizerModel | controller = { controllerModel | selectedPlaces = List.filter (\p -> p.name /= placeName ) controllerModel.selectedPlaces }}}
            , Cmd.none
            )
            
        
        PlaceSearchInput keyword ->
            ( { rootModel | visualizer = { visualizerModel | controller = { controllerModel | placeSearchKeyword = keyword }}}
            , Cmd.none
            )
        
        ErrorMsg subMsg ->
            let
                ( errorPanelModel, cmd ) =
                    Common.ErrorPanel.update subMsg rootModel.errorList
            in
            ( { rootModel | errorList = errorPanelModel}
            , Cmd.map ErrorMsg cmd
            )

view : Model -> Html Msg
view model =
    div [ class "row controller" ]
        [ div [ class "col-12" ]
            [ h2 [] [ text "Controller" ] ]
        , div [ class "col-6"]
            [ text "date" ]
        , div [ class "col-6"]
            [ placesView model.controller ]
        ]


placesView : ControllerModel -> Html Msg
placesView controllerModel  =
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
        ( List.map selectedPlaceBox controllerModel.selectedPlaces )


selectedPlaceBox : Place -> Html Msg
selectedPlaceBox place =
    div [ class "selected-place-box", onClick ( DelSelectedPlace place.name ) ]
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
        ( placesFilter controllerModel.placeSearchKeyword controllerModel.places
            |> List.map (\p -> li [ onClick ( SelectPlace p.name ) ] [text p.name])
        )



-- placeSelectedButton : (Int, Place) -> Html Msg
-- placeSelectedButton (index, place) =
--     button [ type_ "button", class "btn btn-light", onClick (DelSelectedPlace index) ] [ text place.name ]


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
