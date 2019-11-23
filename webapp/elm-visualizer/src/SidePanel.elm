module SidePanel exposing (Msg, update, view)

import Controller
import Data exposing (Model)
import Html exposing (..)
import Html.Attributes exposing (..)
import People



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "sidepanel" ]
        [ h1 [] [ text "Panel" ]
        , People.view model
        , Html.map ControllerMsg (Controller.view model)
        ]



-- UPDATE


type Msg
    = ControllerMsg Controller.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ControllerMsg subMsg ->
            let
                ( model_, cmd ) =
                    Controller.update subMsg model
            in
            ( model_, Cmd.map ControllerMsg cmd )
