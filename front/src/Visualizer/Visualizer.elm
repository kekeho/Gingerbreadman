module Visualizer.Visualizer exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)

import Model exposing (RootModel)
import Visualizer.Model exposing (Model)
import Visualizer.Controller


-- UDPATE

type Msg
    = ControllerMsg Visualizer.Controller.Msg


update : Msg -> RootModel -> ( RootModel, Cmd Msg )
update msg rootModel =
    case msg of
        ControllerMsg subMsg ->
            let
                ( rootModel_, cmd_) =
                    Visualizer.Controller.update subMsg rootModel
                cmd =
                    Cmd.map ControllerMsg cmd_
            in
            ( rootModel_, cmd )

-- VIEW

view : RootModel -> Browser.Document Msg
view rootModel =
    { title = "Visualizer"
    , body =
        [ div [ class "container visualizer" ]
            [ div [ class "row" ]
                [ div [ class "col-7" ] -- Map & Controller
                    [ div [ class "row" ]
                        [ -- MAP 
                        ]
                    , Visualizer.Controller.view rootModel.visualizer
                        |> Html.map ControllerMsg 
                    ]
                , div [ class "col-5" ] -- People, Traffic...
                    []
                ]
            ]
        ]
    }



-- FUNCTIONS

onLoad : Cmd Msg
onLoad =
    Cmd.batch
        ( List.map (\(msg, cmd) -> Cmd.map msg cmd) 
            [ (ControllerMsg, Visualizer.Controller.getPlaces)
            ]
        )