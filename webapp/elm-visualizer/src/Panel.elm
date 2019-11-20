module Panel exposing (viewController)

import Html exposing (..)
import Html.Attributes exposing (..)

import Data exposing (Place, ControllerModel)


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

