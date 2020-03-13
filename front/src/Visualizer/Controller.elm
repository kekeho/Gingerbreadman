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
    div [ class "controller" ]
        [ h2 [] [ text "Controller" ]
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
                [ allPlacesList controllerModel.places ]
            ]

        ]



allPlacesList : List Place -> Html Msg
allPlacesList places =
    li [ class "all-places" ]
        ( List.map (\p -> ul [] [text p.name]) places )



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
