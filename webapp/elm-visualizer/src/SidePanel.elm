module SidePanel exposing (Msg, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)

import Data exposing (Model)
import Controller



-- VIEW

view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Panel" ]
        , Html.map ControllerMsg (Controller.view model)
        ]


-- UPDATE

type Msg
    = ControllerMsg Controller.Msg


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ControllerMsg subMsg ->
            let
                (model_, cmd) =
                    Controller.update subMsg model
            in
                (model_, Cmd.map ControllerMsg cmd)

