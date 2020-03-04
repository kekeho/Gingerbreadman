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
    , uploadResult : Maybe ((Result Http.Error ()))
    }


-- UPDATE

type Msg
    = ImageRequested
    | ImageSelected  File.File (List File.File)
    | Uploaded (Result Http.Error ())


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ImageRequested -> 
            (model, File.Select.files ["image/*"] ImageSelected)
        ImageSelected fstFile files ->
            ( model
            , Http.post
                { url = "/api/upload/"
                , body = Http.multipartBody (List.map (\f -> Http.filePart "images[]" f) (fstFile :: files) )
                , expect = Http.expectWhatever Uploaded
                }
            )
        
        Uploaded result ->
            ( { model | uploadResult = Just result }, Cmd.none )


-- VIEW

view : Model -> Browser.Document Msg
view model =
    { title = "Gingerbreadman | Upload"
    , body =
        [ div [ class "container maincontainer" ]
            [ h1 [] [ text "UPLOAD" ]
            , button [ onClick ImageRequested ] [ text "Upload" ]
            ]
        ]
    }


