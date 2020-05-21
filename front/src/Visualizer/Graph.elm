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
            ]
        ]



w : Float
w = toFloat 500

h : Float
h = toFloat 500



colors : Array Color
colors =
    Array.fromList
        [ rgba255 77 124 191 1  -- MALE
        , rgba255 191 77 134 1  -- FEMALE
        , rgba255 220 220 220 1  -- NotKnown
        , rgba255 220 220 220 1  -- Empty
        ]


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


annular : List Arc -> Svg msg
annular arcs =
    let
        makeSlice index datum =
            Path.element (Shape.arc { datum | innerRadius = radius - 60 })
                [ fill <| Paint <| Maybe.withDefault Color.black <| Array.get index <| colors
                ]
    in
    g [ transform [ Translate radius radius ] ]
        [ g []
            ( List.indexedMap makeSlice arcs )
        , title 0 0 "Sex"
        ]


sexView : List Float -> Html msg
sexView valList =
    let
        valList_ = 
            if Maybe.withDefault 0 (List.maximum valList) > 0 then
                valList
            else
                [0, 0, 0, 1]
        pieData =
            valList_ |> Shape.pie { defaultPieConfig | outerRadius = radius }
    in
    div [ class "graph-svg sex" ]
        [ svg [ width (round w), height (round h) ]
            [ annular <| pieData
            -- , title "Sex"
            ]
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



rgba255 : Int -> Int -> Int -> Float -> Color
rgba255 r g b a =
    Color.fromRgba { red = toFloat r / 255, green = toFloat g / 255, blue = toFloat b / 255, alpha = a }
