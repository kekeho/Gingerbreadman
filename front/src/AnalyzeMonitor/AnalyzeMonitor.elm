module AnalyzeMonitor.AnalyzeMonitor exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (RootModel)
import AnalyzeMonitor.Model exposing (..)
import Http
import Time
import Json.Decode as D
import Common.ErrorPanel


-- UPDATE

type Msg
    = Update Time.Posix
    | GotStatus (Result Http.Error (List ServiceModel))
    | ErrorMsg Common.ErrorPanel.Msg


update : Msg -> RootModel ->  ( RootModel, Cmd Msg )
update msg rootModel =
    case msg of
        Update _ ->
            ( rootModel
            , getStatus
            )

        GotStatus result ->
            case result of
                Ok statusList ->
                    let
                        model =
                            rootModel.analyzeMonitor
                        model_ =
                            { model | services = statusList }
                    in
                     ( { rootModel | analyzeMonitor = model_ }
                     , Cmd.none 
                     )
                
                Err error ->
                    let
                        (rootModel_, cmd_) =
                            update (ErrorMsg (Common.ErrorPanel.AddError { error = Common.ErrorPanel.HttpError error, str = "Network Error"})) rootModel
                    in
                    ( rootModel_
                    , cmd_
                    )
        
        ErrorMsg subMsg ->
            let
                errorModel = rootModel.errorList
                ( errorPaneModel, subMsg_ ) =
                    Common.ErrorPanel.update subMsg errorModel
            in
            ( { rootModel | errorList = errorPaneModel }
            , Cmd.map ErrorMsg subMsg_
            )
        
    



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
        [ div [ class "title-indicator" ]
            [ h2 [ class "title" ] [ text service.service ]
            , hr [] []
            ]
        , div [ class "main-indicator" ]
            [ indicatorView "Remain :" service.remain
            ]
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


-- SUBSCRIPTIONS

subscriptions : RootModel -> Sub Msg
subscriptions _ =
    Time.every 1000 Update



-- FUNC


getStatus : Cmd Msg
getStatus =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Accept" "application/json" ]
        , url = "/api/db/get_analyze_state/"
        , expect = Http.expectJson GotStatus statusDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }


statusDecoder : D.Decoder (List ServiceModel)
statusDecoder =
   D.list singleStatusDecoder


singleStatusDecoder : D.Decoder ServiceModel
singleStatusDecoder =
     D.map4 ServiceModel
        (D.field "service" D.string)
        (D.field "unanalyzed" D.int)
        (D.field "analyzing" D.int)
        (D.field "analyzed" D.int)
