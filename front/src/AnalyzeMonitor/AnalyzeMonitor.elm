module AnalyzeMonitor.AnalyzeMonitor exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
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
    let
        services = rootModel.analyzeMonitor.services
    in
    { title = "Analyze Monitor"
    , body = 
        [ div [ class "horizonal-container analyze-monitor" ]
            (List.map serviceView services)
        ]
    }


serviceView : ServiceModel -> Html Msg
serviceView service =
    div [ class "service pad" ]
        [ h2 [ class "title" ] [ text <| serviceToStr service.service ]
        , hr [] []
        , indicatorView "Remain :" service.remain
        , div [ class "mini-indicator" ]
            [ indicatorView "Analyzing :" service.analyzing
            , indicatorView "Done :" service.analyzed
            ]
        ]


indicatorView : String -> Int -> Html msg
indicatorView title val =
    div [ class "indicator" ]
        [ div [ class "title" ] [ text title ]
        , div [ class "val" ]
            [ text <| String.fromInt val 
            , div [ class "unit" ]
                [ text <| if val > 1 then "items" else "item" ]
            ]
        ]
