module Panel exposing (viewController)

import Html exposing (..)
import Html.Attributes exposing (..)

import Data exposing (Place, Model, ControllerModel)




viewController : Model -> Html msg
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
            , case model.allPlaces of
                Just places ->
                    select [ multiple True ]
                        (List.map placesOptionList places)
                Nothing ->
                    div [ class "error" ] [ text "There are no places" ]
            ]
        
        -- Analyze button
        , div [ class "col-12" ]
            [ button [ type_ "button", class "btn btn-dark" ]
                [ text "Analyze" ]
            ]
        ]


placesOptionList : Place -> Html msg
placesOptionList place =
    option [ value place.name ] [ text place.name ]

