module Visualizer exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)

-- MODEL

type alias Model =
    { test : String
    }


-- UDPATE

type Msg
    = Hoge
    | Fuga


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            (model, Cmd.none)

-- VIEW

view : Model -> Browser.Document Msg
view model =
    { title = "Gingerbreadman | Visualizer"
    , body =
        [ div [ class "container maincontainer" ]
            [ text "visualizer" ]
        ]
    }
