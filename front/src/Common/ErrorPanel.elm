module Common.ErrorPanel exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http


-- MODEL

type Error
    = HttpError Http.Error
    | OnlyStr

    

type alias ErrorModel =
    { error : Error
    , str : String
    }


type alias Model = List ErrorModel
    



-- UPDATE

type Msg
    = AddError ErrorModel
    | DelError Int


update : Msg -> Model ->  ( Model, Cmd Msg )
update msg model =
    case msg of
        AddError error ->
            ( error :: model
            , Cmd.none )

        DelError index ->
            let
                newList =
                    List.filter (\(idx, err) -> idx /= index) (List.indexedMap Tuple.pair model)
                        |> List.map (\(idx, err) -> err)
            in
            ( newList
            , Cmd.none )



-- VIEW

view : List ErrorModel -> Html Msg
view errorList =
    div [ class "errorList" ]
        ( List.indexedMap Tuple.pair errorList
            |> List.map errorBoxView
        )


errorBoxView : (Int, ErrorModel) -> Html Msg
errorBoxView (index, error) =
    div [ class "errorBox row" ]
        [ div [ class "title col-10" ]
            [ text error.str ]
        , div [ class "delButton col-2", onClick (DelError index) ]
            [ text "✕" ]
        ]
    
