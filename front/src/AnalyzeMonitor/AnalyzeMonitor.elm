module AnalyzeMonitor.AnalyzeMonitor exposing (..)

import Browser
import Html exposing (..)
import Model exposing (RootModel)
import AnalyzeMonitor.Model exposing (..)


-- UPDATE

type Msg
    = Message


update : Msg -> RootModel ->  ( RootModel, Cmd Msg )
update msg rootModel =
    case msg of
        Message ->
             ( rootModel, Cmd.none )


-- VIEW

view : RootModel -> Browser.Document Msg
view rootModel =
    { title = "Analyze Monitor"
    , body = 
        [ div [] [ text "monitor" ]
        ]
    }
    