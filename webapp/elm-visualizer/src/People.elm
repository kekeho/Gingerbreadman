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
        , div [ class "col-12" ]
            [ viewTrafficCount model ]
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
    div [ class "col-4", style "background-color" (rgbColorToCssString person.color) ]
        [ div [ class "row face-row" ] imgs
        , div [ class "row" ]
            [ placesHistoryString person ]
        ]


viewTrafficCount : Model -> Html msg
viewTrafficCount model =
    let
        traffics =
            case model.people of
                Just p ->
                    Just (Data.getTraffic p)

                Nothing ->
                    Nothing
    in
    case traffics of
        Just t ->
            div []
                (List.map trafficString t
                    |> List.map (\s -> div [] [ text s ])
                )

        Nothing ->
            div []
                [ text "" ]


trafficString : Data.Traffic -> String
trafficString traffic =
    let
        places =
            traffic.places

        head =
            List.head places

        body =
            List.drop 1 places
                |> List.map .name
    in
    case head of
        Just h ->
            h.name ++ List.foldl (\n p -> p ++ " -> " ++ n) "" body ++ ": " ++ String.fromInt traffic.count

        Nothing ->
            ""


placesHistoryString : Person -> Html msg
placesHistoryString person =
    let
        faces =
            person.faces

        places =
            List.map (\f -> f.place) faces

        head =
            List.head places

        body =
            List.drop 1 places
                |> List.map (\p -> p.name)
    in
    case head of
        Just h ->
            text (h.name ++ List.foldl (\n p -> p ++ " -> " ++ n) "" body)

        Nothing ->
            text "No history"


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
