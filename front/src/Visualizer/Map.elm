port module Visualizer.Map exposing (..)

import Common.Data exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Model exposing (..)
import Visualizer.Model exposing (..)



-- update


type Msg
    = Update


update : Msg -> RootModel -> ( RootModel, Cmd Msg )
update msg rootModel =
    case msg of
        Update ->
            let
                mapUpdate =
                    [ drawPlaceCircle rootModel.visualizer.people
                    , drawTrafficLine rootModel.visualizer.traffic
                    ]
            in
            ( rootModel
            , Cmd.batch mapUpdate
            )



-- ports


port initMap : String -> Cmd msg


port clearMap : String -> Cmd msg


port drawPlaceCirclePort : List ( Place, Int ) -> Cmd msg


port drawTrafficLinePort : List ( TrafficCount, List TrafficCount ) -> Cmd msg



-- VIEW


mapView : String -> Html msg
mapView mapId =
    div [ id mapId, class "map" ] []



-- CMD


drawPlaceCircle : List Person -> Cmd msg
drawPlaceCircle people =
    uniquePeopleCount people
        |> drawPlaceCirclePort


drawTrafficLine : List TrafficCount -> Cmd msg
drawTrafficLine trafficList =
    bidirectionalTrafficList trafficList
        |> drawTrafficLinePort



-- FUNCTIONS


uniquePeopleCount : List Person -> List ( Place, Int )
uniquePeopleCount people =
    List.map personPlacesNoDuplicate people
        |> List.concat
        |> placesCount


bidirectionalTrafficList : List TrafficCount -> List ( TrafficCount, List TrafficCount )
bidirectionalTrafficList trafficCountList =
    case trafficCountList of
        [] ->
            []

        x :: xs ->
            let
                same =
                    List.filter (\t -> Tuple.first x.traffic == Tuple.second t.traffic && Tuple.second x.traffic == Tuple.first t.traffic) xs

                others =
                    List.filter (\t -> x /= t && not (List.member t same)) xs
            in
            ( x, same ) :: bidirectionalTrafficList others



-- Helpers


personPlacesNoDuplicate : Person -> List Place
personPlacesNoDuplicate person =
    List.map .place person
        |> uniqueList


uniqueList : List a -> List a
uniqueList list =
    List.foldr consIfNotMember [] list


consIfNotMember : a -> List a -> List a
consIfNotMember el list =
    if List.member el list then
        list

    else
        el :: list


placesCount : List Place -> List ( Place, Int )
placesCount places =
    case List.head places of
        Just place ->
            case List.tail places of
                Just tail ->
                    ( place
                    , List.filter (\p -> p == place) tail
                        |> List.length
                        |> (\i -> i + 1)
                    )
                        :: placesCount (List.filter (\p -> p /= place) tail)

                Nothing ->
                    [ ( place, 1 ) ]

        Nothing ->
            []
