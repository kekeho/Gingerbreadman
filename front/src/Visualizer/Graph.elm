module Visualizer.Graph exposing (..)


import Array exposing (Array)
import Color exposing (Color)
import LowLevel.Command exposing (arcTo, clockwise, largestArc, moveTo)
import Path
import Shape exposing (Arc, defaultPieConfig)
import TypedSvg exposing (circle, g, svg, text_)
import TypedSvg.Attributes exposing (fill, fontSize, fontWeight, stroke, color,transform, textAnchor,viewBox, dy)
import TypedSvg.Attributes.InPx exposing (cx, cy, r)
import TypedSvg.Core exposing (Svg)
import TypedSvg.Types exposing (Paint(..), Transform(..), AnchorAlignment(..), em)
import Html exposing (..)
import Html.Attributes exposing (..)

import Visualizer.Model exposing (..)
import Model exposing (..)


type GraphType
    = Sex
    | Age


-- UPDATE


type Msg =
    Message


update : Msg -> RootModel ->  ( RootModel, Cmd Msg )
update msg rootModel =
    case msg of
        _ ->
             ( rootModel, Cmd.none )


-- VIEWS

view : RootModel -> Html Msg
view rootModel =
    div [ class "graph column", id "graph" ]
        [ h2 [ class "title" ] [ text "Graph" ]
        , div [ class "graph-container depression-container" ]
            [ sexView <| sexPer rootModel.visualizer.people
            , ageView <| agePer rootModel.visualizer.people
            ]
        ]



w : Float
w = toFloat 250

h : Float
h = toFloat 250


radius : Float
radius = Basics.min (w/2) h/2-10


title : Float -> Float -> String -> Svg msg
title x y txt =
    text_
        [ transform [ Translate x y ]
        , dy (TypedSvg.Types.em 0.5)
        , textAnchor AnchorMiddle
        , fontSize (TypedSvg.Types.em 1.5)
        , fontWeight TypedSvg.Types.FontWeightBold
        , fill <| Paint <| rgba255 110 110 110 1
        ]
        [ text txt ]


labelText : Float -> Float -> String -> Svg msg
labelText x y txt =
    text_
        [ transform [ Translate x y ]
        , dy (TypedSvg.Types.em 0.5)
        , textAnchor AnchorMiddle
        , fontSize (TypedSvg.Types.em 0.8)
        , fontWeight TypedSvg.Types.FontWeightBold
        , fill <| Paint <| rgba255 70 70 70 1
        ]
        [ text txt ]


nonSort : comparable -> comparable -> Order
nonSort _ _ =
    GT

annular : GraphType -> Array Color -> String -> List Arc -> List Float -> Bool -> Svg msg
annular graphType colorArray titleStr arcs valList labelVisible =
    let
        makeSlice index datum =
            Path.element (Shape.arc { datum | innerRadius = radius * 2 - 10 })
                [ fill <| Paint <| Maybe.withDefault Color.black <| Array.get index <| colorArray
                ]
        makeLabels index (datum, val) =
            let
                (x, y) =
                    Shape.centroid { datum | innerRadius = radius * 2, outerRadius = radius * 2 + 10}
                labelT =
                    if labelVisible then
                        case graphType of
                            Sex ->
                                let
                                    head =
                                        case index of
                                            0 ->
                                                "Male"
                                            1 ->
                                                "Female"
                                            2 ->
                                                "Not Known"
                                            _ ->
                                                "ERROR"
                                in
                                head ++ " : " ++ String.fromFloat ((val / List.sum valList)*100) ++ "%"
                            Age ->
                                String.fromInt (index*5) ++ "~" ++ String.fromInt ((index+1)*5)
                                ++ " : " ++ String.fromFloat ((val / List.sum valList)*100) ++ "%"
                    else
                        ""
            in
            labelText x y labelT
    in
    g [ transform [ Translate (w/2) (w/2) ] ]
        [ g []
            ( List.indexedMap makeSlice <| arcs
            )
        , g [] (List.indexedMap makeLabels <| List.map2 Tuple.pair arcs valList )
        , title 0 0 titleStr
        ]


sexColors : Array Color
sexColors =
    Array.fromList
        [ rgba255 77 124 191 1  -- MALE
        , rgba255 191 77 134 1  -- FEMALE
        , rgba255 220 220 220 1  -- NotKnown
        , rgba255 220 220 220 1  -- Empty
        ] 


sexView : List Float -> Html msg
sexView valList =
    let
        (valList_, labelVisible) = 
            if Maybe.withDefault 0 (List.maximum valList) > 0 then
                (valList, True)
            else
                ([0, 0, 0, 1], False)
        pieData =
            valList_ |> Shape.pie { defaultPieConfig | outerRadius = radius, sortingFn = nonSort }
    in
    div [ class "graph-svg sex" ]
        [ svg [ width (round w), height (round h) ]
            [ annular Sex sexColors "Sex" pieData valList_ labelVisible ]
        ]


ageColors : Array Color
ageColors =
    List.repeat 8
        [ rgba255 255 255 255 1
        , rgba255 190 190 190 1
        ] 
        |> List.concat
        |> List.append [ rgba255 220 220 220 1 ]  -- NotKnown
        |> Array.fromList


ageView : List Float -> Html msg
ageView valList =
    let
        (valList_, labelVisible) =
            if Maybe.withDefault 0 (List.maximum valList) > 0 then
                (valList, True)
            else
                ( List.map (\_ -> 0) (List.range 1 17)  -- 0~5 -> over 80
                    |> List.append [1] -- empty
                , False
                )
        
        pieData =
            valList_ |> Shape.pie { defaultPieConfig | outerRadius = radius, sortingFn = nonSort }
    in
    div [ class "graph-svg age" ]
        [ svg [ width (round w), height (round h) ]
            [ annular Age ageColors "Age" pieData valList_ labelVisible ]
        ]




-- FUNCTIONS


sexPer : List Person -> List Float
sexPer people =
    let
        m =
            List.filter (\p -> sexDetect p == Male) people
                |> List.length
        f =
            List.filter (\p -> sexDetect p == Female) people
                |> List.length
        n =
            List.filter (\p -> sexDetect p == NotKnown) people
                |> List.length
        
    in
    List.map Basics.toFloat [m, f, n]



sexDetect : Person -> Sex
sexDetect person =
    let
        m = List.filter (\face -> face.sex == Male) person
            |> List.length
        f = List.filter (\face -> face.sex == Female) person
            |> List.length
    in
    case compare m f of
        LT ->
            Female
        GT ->
            Male
        EQ ->
            NotKnown


agePer : List Person -> List Float
agePer people =
    let
        averageList = List.map averageAge people
    in
    List.map
        ( \u -> List.filter (\x -> x >= u-5 && x < u ) averageList |> List.length |> toFloat )
        ( List.map (\i -> toFloat i*5) (List.range 1 16) ) -- 0~4 -> 75~79
    |> List.append [ List.filter (\x -> x >= 80) averageList |> List.length |> toFloat ] -- over 80

averageAge : Person -> Float
averageAge person =
    let
        ageList = List.filterMap .age person
        average =
            List.sum ageList / toFloat (List.length ageList)
    in
    average


rgba255 : Int -> Int -> Int -> Float -> Color
rgba255 r g b a =
    Color.fromRgba { red = toFloat r / 255, green = toFloat g / 255, blue = toFloat b / 255, alpha = a }
