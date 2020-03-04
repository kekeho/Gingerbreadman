module Visualizer exposing (..)

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

