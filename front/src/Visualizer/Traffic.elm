module Visualizer.Traffic exposing (..)

import Common.Data
import Html exposing (..)
import Html.Attributes exposing (..)
import Visualizer.Model exposing (..)



-- VIEW


view : Model -> Html msg
view model =
    div [ class "row traffic" ]
        [ div [ class "col-12" ]
            [ h2 [] [ text "Traffic" ] ]
        , div [ class "col-12" ]
            [ trafficView model.traffic
            ]
        ]


trafficView : List TrafficCount -> Html msg
trafficView trafficList =
    let
        sorted =
            List.sortBy .count trafficList
                |> List.reverse

        top6 =
            List.take 6 sorted

        under6 =
            List.drop 6 sorted
    in
    div [ class "row" ]
        [ div [ class "col-12 top6" ]
            (List.map (\t -> text (trafficCountString t)) top6
                |> List.map (\t -> p [] [ t ])
            )
        , div [ class "col-12 under6" ]
            (List.map (\t -> text (trafficCountString t)) under6
                |> List.map (\t -> p [] [ t ])
            )
        ]



-- FUNCTIONS


f : List Person -> List TrafficCount
f people =
    let
        sorted =
            List.map sortWithTime people

        allTraffic =
            List.map personTrafficList sorted
                |> List.concat
    in
    case List.head allTraffic of
        Nothing ->
            []

        Just traffic ->
            h traffic allTraffic []


personTrafficList : Person -> List Traffic
personTrafficList person =
    case listIndex 0 person of
        Just face ->
            case listIndex 1 person of
                Just nextFace ->
                    ( face.place, nextFace.place ) :: personTrafficList (List.drop 1 person)

                Nothing ->
                    []

        Nothing ->
            []


listIndex : Int -> List a -> Maybe a
listIndex index list =
    List.drop index list
        |> List.head


h : Traffic -> List Traffic -> List TrafficCount -> List TrafficCount
h traffic trafficList trafficCountList =
    let
        count =
            List.filter ((==) traffic) trafficList
                |> List.length

        withoutList =
            List.filter ((/=) traffic) trafficList

        nextTraffic =
            List.head withoutList
    in
    case nextTraffic of
        Nothing ->
            TrafficCount traffic count :: trafficCountList

        Just next ->
            h next withoutList (TrafficCount traffic count :: trafficCountList)


trafficCountString : TrafficCount -> String
trafficCountString trafficCount =
    let
        ( from, to ) =
            trafficCount.traffic

        count =
            trafficCount.count
    in
    from.name ++ " -> " ++ to.name ++ " : " ++ String.fromInt count
