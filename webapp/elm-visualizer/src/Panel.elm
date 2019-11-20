module Panel exposing (viewController, ControllerModel)

import Html exposing (..)
import Html.Attributes exposing (..)

import Person exposing (Place)


viewController :  Maybe ControllerModel -> Html msg
viewController controller =
    div [ class "row" ]
        [ div [class "col"]
            [ h1 [] [ text "Controller" ]]
        ]


-- MODEL

type alias ControllerModel =
    { fromTimeString : String 
    , toTimeString : String
    , places : List Place
    }