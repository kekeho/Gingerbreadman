module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as D exposing (Decoder)

import Person exposing (..)


-- MAIN

main : Program () Model Msg
main =
    Browser.element 
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


-- MODEL

init : () -> (Model, Cmd Msg)
init _ =
    ({controller = Nothing, people = Nothing}, Cmd.none)


type alias Model =
    { controller : Maybe ControllerModel
    , people : Maybe (List Person)
    }


type alias ControllerModel =
    { fromTimeString : String 
    , toTimeString : String
    , places : List Place
    }



-- UDPATE

type Msg
    = SetController ControllerModel
    | Analyze
    | Analyzed


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        _ ->
            (model, Cmd.none)



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ div [ class "row" ]
            [ div [ class "col-7" ]
                [ h1 []
                    [ text "Map" ]
                ]
            , div [ class "col-5" ]
                [ h1 []
                    [ text "Panel" ]
                ]
            ]
        ]
