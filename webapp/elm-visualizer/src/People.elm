module People exposing (..)

import Data exposing (Model, Person)
import Html exposing (..)
import Html.Attributes exposing (..)



-- VIEW


view : Model -> Html msg
view model =
    div [ class "row" ]
        [ div [ class "col-12" ]
            [ h1 [] [ text "People" ] ]
        , div [ class "col-12" ]
            [ viewPersonRow model ]
        ]


viewPersonRow : Model -> Html msg
viewPersonRow model =
    div [ class "row" ]
        (case model.people of
            Just personList ->
                List.map viewPerson personList

            Nothing ->
                []
        )


viewPerson : Person -> Html msg
viewPerson person =
    let
        imgs =
            List.map (\f -> div [ class "col-4 face-col" ] [ imageWithBase64 f.faceImageB64 "face-img" ]) person.faces
    in
    div [ class "col-4", style "background-color: " (rgbColorToCssString person.color ++ ";") ]
        [ div [ class "row face-row" ] imgs ]


rgbColorToCssString : Data.RgbColor -> String
rgbColorToCssString color =
    "rgb("
        ++ String.fromInt color.r
        ++ ", "
        ++ String.fromInt color.g
        ++ ", "
        ++ String.fromInt color.b
        ++ ")"


imageWithBase64 : String -> String -> Html msg
imageWithBase64 b64 className =
    img [ src b64, class className ] []
