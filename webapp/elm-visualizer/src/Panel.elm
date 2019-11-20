module Panel exposing (viewController, ControllerModel)

import Html exposing (..)
import Html.Attributes exposing (..)

import Person exposing (Place)


viewController : ControllerModel -> Html msg
viewController controller =
    div [ class "row" ]
        [ div [ class "col-12" ]
            [ h1 [] [ text "Controller" ] ]
        , div [class "col-6"]
            [ h2 [] [ text "Time" ]
            , input [ type_ "datetime-local", placeholder "FROM", value controller.fromTimeString] []
            , input [ type_ "datetime-local", placeholder "TO", value controller.toTimeString ] []
            ]

        , div [class "col-6"]
            [ h2 [] [ text "Places" ]

            ]
        ]


-- viewPlacesTags : List Place -> Html msg



-- MODEL

type alias ControllerModel =
    { fromTimeString : String 
    , toTimeString : String
    , places : Maybe (List Place)
    }