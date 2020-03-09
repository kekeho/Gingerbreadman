module Upload exposing (..)

import Browser
import CommonData exposing (..)
import File
import File.Select
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import List



-- MODEL


type alias Model =
    { places : Maybe (List Place)
    , selectedPlace : Maybe Place
    , newPlace : Place
    , selectedImages : Maybe (List File.File)
    , getPlacesError : Maybe Http.Error
    , uploadResult : Maybe (Result Http.Error ())
    }



-- UPDATE


type Msg
    = ImageRequested
    | ImageSelected File.File (List File.File)
    | Upload
    | Uploaded (Result Http.Error ())
    | GotPlaces (Result Http.Error (List Place))
    | PlaceSelected String
    | NewPlaceName String
    | NewPlaceLongitude String
    | NewPlaceLatitude String
    | ErrorDialog String

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ImageRequested ->
            ( model, File.Select.files [ "image/*" ] ImageSelected )

        ImageSelected fstFile files ->
            ( { model | selectedImages = Just (fstFile :: files) }
            , Cmd.none
            )

        Upload ->
            case model.selectedImages of
                Nothing ->
                    update (ErrorDialog "NO IMAGE") model
                Just files ->
                    case model.selectedPlace of
                        Nothing ->
                            update (ErrorDialog "NO SELECTED PLACE") model
                    
                        Just selectedPlace ->
                            ( model
                            , Http.post
                                { url = "/api/db/regist_images/"
                                , body =
                                    Http.multipartBody 
                                        (  (Http.stringPart "place_selected" selectedPlace.name)
                                        :: (Http.stringPart "place_new" model.newPlace.name)
                                        :: (Http.stringPart "new_latitude" (String.fromFloat model.newPlace.latitude))
                                        :: (Http.stringPart "new_longitude" (String.fromFloat model.newPlace.longitude))
                                        :: (List.map (\f -> Http.filePart "images" f) files)
                                        ++ (List.map (\f -> Http.stringPart "images_mtimes" (msecToStr (File.lastModified f))) files)
                                        )
                                , expect = Http.expectWhatever Uploaded
                                }
                            )



        Uploaded result ->
            ( { model | uploadResult = Just result }, Cmd.none )

        GotPlaces result ->
            case result of
                Ok places ->
                    ( { model | places = Just places, getPlacesError = Nothing, selectedPlace = List.head places }
                    , Cmd.none
                    )

                Err error ->
                    ( { model | getPlacesError = Just error, places = Nothing }
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
        
        NewPlaceName name ->
            let
                newPlace = model.newPlace
            in
            ( { model | newPlace = { newPlace | name = name }
              }
            , Cmd.none
            )
        
        NewPlaceLatitude latitude ->
            let
                newPlace = model.newPlace
                lat =
                    case String.toFloat latitude of
                        Just l ->
                            l
                        Nothing ->
                            0.0
            in
            ( { model | newPlace = { newPlace | latitude = lat } }
            , Cmd.none
            )
        
        NewPlaceLongitude longitude ->
            let
                newPlace = model.newPlace
                lon =
                    case String.toFloat longitude of
                        Just l ->
                            l
                        Nothing ->
                            0.0
            in
            ( { model | newPlace = { newPlace | longitude = lon } }
            , Cmd.none
            )
        
        ErrorDialog errString ->
            -- TODO: エラーダイアログ
            ( model, Cmd.none )




-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Upload"
    , body =
        [ div [ class "container" ]
            [ div [ class "row" ]
                [ div [ class "col upload-form" ]
                    [ div [ class "form-row" ]
                        [ div [ class "col" ]
                            [ h1 [ class "title" ] [ text "Upload Images" ]
                            , button [ onClick ImageRequested ] [ text "Select Images" ]
                            , filesCountView model.selectedImages
                            ]
                        ]
                    , div [ class "form-row" ]
                        [ div [ class "col-lg-12" ]
                            [ h2 [] [ text "Select place tag" ] ]
                        , selectPlacesView model
                        , newPlacesView model
                        ]
                    , div [ class "form-row" ]
                        [ div [ class "col" ]
                            [ input 
                                [ class "form-control" 
                                , type_ "submit"
                                , value "Upload"
                                , onClick Upload
                                ]
                                [ ]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    }


selectPlacesView : Model -> Html Msg
selectPlacesView model =
    div [ class "col" ]
        [ label [] [ text "Existing Places" ]
        , select [ class "form-control", onChange PlaceSelected ]
            (case model.places of
                Just places ->
                    List.map (\p -> option [ value p.name ] [ text p.name ]) places

                Nothing ->
                    []
            )
        ]


filesCountView : Maybe (List File.File) -> Html Msg
filesCountView maybeFiles =
    Html.p []
        (case maybeFiles of
            Just files ->
                let
                    count =
                        List.length files
                    pluralStr =
                        if count >= 2 then "s" else ""
                in
                [ text (String.fromInt count ++ " file" ++ pluralStr) ]

            Nothing ->
                []
        )


newPlacesView : Model -> Html Msg
newPlacesView model =
    div [ class "col" ]
        [ input
            [ type_ "text"
            , class "form-control"
            , placeholder "or create new place tag"
            , onChange NewPlaceName
            , value model.newPlace.name ]
            [ ]

        , input
            [ type_ "number"
            , placeholder "latitude"
            , step "0.0000001"
            , onChange NewPlaceLatitude
            , value (String.fromFloat model.newPlace.latitude)
            ]
            [ ]
        , input
            [ type_ "number"
            , placeholder "longitude"
            , step "0.0000001"
            , value (String.fromFloat model.newPlace.longitude)
            , onChange NewPlaceLongitude
            ]
            [ ]
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
