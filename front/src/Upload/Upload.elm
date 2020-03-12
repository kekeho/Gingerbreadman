module Upload.Upload exposing (..)

import Browser
import Common.Data exposing (..)
import File
import File.Select
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import List

import Common.ErrorPanel as ErrorPanel
import Upload.Model exposing (Model)






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
    | PlaceSearchInput String
    | ErrorMsg ErrorPanel.Msg

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
                    update (ErrorMsg (ErrorPanel.AddError { error = ErrorPanel.OnlyStr, str = "NO IMAGE"})) model

                Just files ->
                    case model.selectedPlace of
                        Nothing ->
                            update (ErrorMsg (ErrorPanel.AddError { error = ErrorPanel.OnlyStr, str = "NO SELECTED PLACE"})) model
                    
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
            case result of
                Ok _ ->
                    ( { model | selectedImages = Nothing }
                    , Cmd.none )

                Err error ->
                    update (ErrorMsg (ErrorPanel.AddError { error = (ErrorPanel.HttpError error), str = "Failed to upload images"})) model

        GotPlaces result ->
            case result of
                Ok places ->
                    ( { model | places = Just places, getPlacesError = Nothing, selectedPlace = List.head places, placeSearchFiltered = places }
                    , Cmd.none
                    )

                Err error ->
                    let
                        (newModel, cmd) =
                            update (ErrorMsg (ErrorPanel.AddError { error = (ErrorPanel.HttpError error), str = "Failed to load location tags"})) model
                    in
                    ( { newModel | places = Nothing, placeSearchFiltered = [] }
                    , cmd
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
        
        PlaceSearchInput keyword ->
            let
                lowerKeyword = String.toLower keyword
                filteredPlaces =
                    case model.places of
                        Just places ->
                            List.filter (\p -> String.contains lowerKeyword (String.toLower p.name)) places
                        Nothing ->
                            []
            in
            ( { model | placeSearchFiltered = filteredPlaces, placeSearchInput = keyword }
            , Cmd.none
            )
            
        
        ErrorMsg subMsg ->
            let
                (model_, cmd) =
                    ErrorPanel.update subMsg model.error
            in
                ( { model | error = model_ }
                , Cmd.map ErrorMsg cmd)


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

        -- Errors
        , div [ class "errorPanel" ]
                    [ Html.map ErrorMsg (ErrorPanel.view model.error) ]
        ]
    }


selectPlacesView : Model -> Html Msg
selectPlacesView model =
    div [ class "col" ]
        [ label [] [ text "Existing Places" ]
        , input [ type_ "text", onChange PlaceSearchInput, placeholder "Search Place", value model.placeSearchInput ] []
        , select [ class "form-control", Html.Events.onInput PlaceSelected ]
            (List.map (\p -> option [ value p.name ] [ text p.name ]) model.placeSearchFiltered)
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
