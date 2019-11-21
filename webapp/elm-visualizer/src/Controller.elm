module Controller exposing (viewController, Msg, update)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Url.Builder
import Http

import Data exposing (Place, Model, ControllerModel)


-- UPDATE

type Msg
    = AddSelectedPlace Int Place
    | DelSelectedPlace Int
    | SetFromTime String
    | SetToTime String
    | Analyze
    | Analyzed (Result Http.Error String)



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        AddSelectedPlace index place ->
            ({ model
            | controller =
                let 
                    controller = model.controller
                in
                    { controller
                    | places = 
                        case controller.places of
                            Just places ->
                                case addChecker places place of
                                    True ->
                                        Just (place :: places)
                                    False ->
                                        Just places
                            Nothing ->
                                Just [place]
                    }
            }, Cmd.none)


        DelSelectedPlace index ->
            ({ model
            | controller =
                let
                    controller = model.controller
                    old = controller.places
                in
                    { controller
                    | places =
                        case old of
                            Just places ->
                                Just ((List.take index places) ++ (List.drop (index+1) places))
                            Nothing ->
                                Nothing
                    }
            }, Cmd.none)
            

        SetFromTime time ->
            ({ model
            | controller =
                let
                    controller = model.controller
                in
                    { controller | fromTimeString = time }
            }
            , Cmd.none
            )
        

        SetToTime time ->
            ({ model
            | controller =
                let
                    controller = model.controller
                in
                    { controller | toTimeString = time }
            }
            , Cmd.none
            )
        
        
        Analyze ->
            ( model
            , 
            
            let
                path = Url.Builder.absolute ["visualizer", "grouping"]
            in
                case groupingQuery model of
                    Just query ->
                        Http.get
                            { url = path query
                            , expect = Http.expectString Analyzed
                            }
                    Nothing ->
                        Cmd.none

            
            )
        _ ->
            (model, Cmd.none)



-- VIEW

viewController : Model -> Html Msg
viewController model =
    div [ class "row" ]
        [ div [ class "col-12" ]
            [ h1 [] [ text "Controller" ] ]
        
        -- Time selector
        , div [class "col-6"]
            [ h2 [] [ text "Time" ]
            , input [ type_ "datetime-local", placeholder "FROM", value model.controller.fromTimeString] []
            , input [ type_ "datetime-local", placeholder "TO", value model.controller.toTimeString ] []
            ]

        -- Places selector
        , div [class "col-6"]
            [ h2 [] [ text "Places" ]
            , div [ class "row"]
                [ div [ class "col-12" ]
                    -- Selected places indicator
                    [ case model.controller.places of
                        Just places ->
                            div [ class "places_selected" ]
                                (List.indexedMap placeSelectedButton places)
                        Nothing ->
                            div [] [ text "Choose locations" ]
                     ]

                , div [ class "col-12"]
                    -- All places
                    [ case model.allPlaces of
                        Just places ->
                            div [ class "places_choice" ]
                                (List.indexedMap placeSelectButton places)
                        Nothing ->
                            div [ class "error" ] [ text "There are no places" ]
                    ]
                ]
            ]
        
        -- Analyze button
        , div [ class "col-12" ]
            [ button [ type_ "button", class "btn btn-dark", onClick Analyze ]
                [ text "Analyze" ]
            ]
        ]


placeSelectButton : Int -> Place -> Html Msg
placeSelectButton index place =
    button [ type_ "button", class "btn btn-secondary", onClick (AddSelectedPlace index place) ] [ text place.name ]


placeSelectedButton : Int -> Place -> Html Msg
placeSelectedButton index place =
    button [ type_ "button", class "btn btn-light", onClick (DelSelectedPlace index)] [ text place.name ]




addChecker : List Place -> Place -> Bool
addChecker places place =
    let
        filterd = List.filter (\p -> p.name == place.name) places
    in
        List.isEmpty filterd


groupingQuery : Model -> Maybe (List Url.Builder.QueryParameter)
groupingQuery model =
    let
        timeQuery =
            [ Url.Builder.string "datetime-from" model.controller.fromTimeString
            , Url.Builder.string "datetime-to" model.controller.toTimeString
            ]
    in
        case model.controller.places of
            Just places ->
                Just
                    ( timeQuery
                    ++ List.map (\p -> Url.Builder.string "places" p.name) places
                    )
            Nothing ->
                Nothing


