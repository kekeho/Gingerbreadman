module Upload exposing (..)

import CommonData exposing (..)
import File
import File.Select
import Http
import List
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Browser

-- MODEL

type alias Model =
    { places : Maybe (List Place)
    , selectedPlace : Maybe Place
    , selectedImages : Maybe (List File.File)
    , getPlacesError : Maybe Http.Error
    , uploadResult : Maybe ((Result Http.Error ()))
    }


-- UPDATE

type Msg
    = ImageRequested
    | ImageSelected  File.File (List File.File)
    | Upload
    | Uploaded (Result Http.Error ())
    | GotPlaces (Result Http.Error (List Place))
    | PlaceSelected String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ImageRequested -> 
            (model, File.Select.files ["image/*"] ImageSelected)
        ImageSelected fstFile files ->
            ( { model | selectedImages = Just (fstFile :: files) }
            , Cmd.none
            )
        
        Upload ->
            case model.selectedImages of
                Just files ->
                    ( model
                    , Http.post
                        { url = "/api/upload/"
                        , body = Http.multipartBody (List.map (\f -> Http.filePart "images[]" f) files )
                        , expect = Http.expectWhatever Uploaded
                        }
                    )
                Nothing ->
                    ( model
                    , Cmd.none
                    )
        
        Uploaded result ->
            ( { model | uploadResult = Just result }, Cmd.none )
        
        GotPlaces result ->
            case result of
                Ok places ->
                    ({ model | places = Just places, getPlacesError = Nothing }
                    , Cmd.none
                    )
                
                Err error ->
                    ({ model | getPlacesError = Just error, places = Nothing}
                    , Cmd.none
                    )
        
        PlaceSelected placeString ->
            let
                place = 
                    case model.places of
                        Just places ->
                            List.filter (\p -> p.name == placeString) places
                                |> List.head
                        Nothing ->
                            Nothing
            in
            ( { model | selectedPlace = place }, Cmd.none )



-- VIEW

view : Model -> Browser.Document Msg
view model =
    { title = "Upload"
    , body =
        [ div [ class "container" ]
            [ div [ class "row" ]
                [ div [ class "col upload-form" ]
                    [ div [ class "form-row" ]
                        [ div [ class "col"]
                            [ h1 [ class "title" ] [ text "Upload Images" ]
                            , button [ onClick ImageRequested ] [ text "Select Images" ]
                            ]
                        ]
                    , div [ class "form-row"]
                        [ div [ class "col-lg-12" ]
                            [ h2 [ ]  [  text "Select place tag" ] ]
                        , selectPlacesView model
                        ]
                    ]

                ]

            ]
        ]
    }


selectPlacesView : Model -> Html Msg
selectPlacesView model =
    div [ class "col" ]
        [ label [] [ text "Existing Places"]
        , select [ class "form-control", onChange PlaceSelected ]
            ( case model.places of
                Just places ->
                    (List.map (\p -> option [ value p.name ] [ text p.name ]) places )
                        
                Nothing ->
                    [ ]
            )
        ]

-- FUNC

getPlaces : Cmd Msg
getPlaces =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Accept" "application/json"
            ]
        , url = "/api/db/get_places_all/"
        , expect = Http.expectJson GotPlaces placesDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }


