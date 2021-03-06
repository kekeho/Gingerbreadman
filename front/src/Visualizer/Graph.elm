port module Visualizer.Graph exposing (..)

import Array exposing (Array)
import Axis
import Color exposing (Color)
import Common.Data exposing (Place)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import LowLevel.Command exposing (arcTo, clockwise, largestArc, moveTo)
import Model exposing (..)
import Path
import Scale exposing (BandConfig, BandScale, ContinuousScale, defaultBandConfig)
import Shape exposing (Arc, defaultPieConfig)
import Time
import Time.Extra
import TypedSvg exposing (circle, g, svg, text_, rect)
import TypedSvg.Attributes exposing (color, dy, fill, fontSize, fontWeight, stroke, textAnchor, transform, viewBox)
import TypedSvg.Attributes.InPx exposing (cx, cy, r, x, y, height, width)
import TypedSvg.Core exposing (Svg)
import TypedSvg.Types exposing (AnchorAlignment(..), Paint(..), Transform(..), em)
import Visualizer.Model exposing (..)


type GraphType
    = Sex
    | Age



-- UPDATE


type Msg
    = PlaceClicked String
    | RemoveFocusPlace Place
    | SexFocus (Maybe Sex)


update : Msg -> RootModel -> ( RootModel, Cmd Msg )
update msg rootModel =
    let
        visualizerModel = rootModel.visualizer
        graphModel = visualizerModel.graph
        graphFocusPlaces = graphModel.focusPlaces

        graphFocusSex = graphModel.focusSex
        resultAllPlaces = rootModel.visualizer.controller.resultPlaces
    in
    case msg of
        PlaceClicked placeName ->
            case List.filter (\p -> p.name == placeName) resultAllPlaces of
                [] ->
                    -- Unknown click
                    ( rootModel, Cmd.none )
                _ -> 
                    -- Remove or Add
                    let
                        graphFocusPlaces_ =
                            case List.filter (\p -> p.name == placeName) graphFocusPlaces of
                                [] -> -- Add
                                    graphFocusPlaces ++ List.filter (\p -> p.name == placeName) resultAllPlaces
                                _ -> -- Remove
                                    List.filter (\p -> p.name /= placeName) graphFocusPlaces
                    in
                    ( { rootModel |
                        visualizer = { visualizerModel |
                            graph = {graphModel | 
                                focusPlaces = graphFocusPlaces_ }}}
                    , Cmd.none
                    )

        RemoveFocusPlace place ->
            let
                graphFocusPlaces_ =
                    List.filter ((/=) place) graphFocusPlaces
            in
            ( { rootModel |
                visualizer = { visualizerModel |
                    graph = { graphModel | 
                        focusPlaces = graphFocusPlaces_ }}}
            , Cmd.none
            )
        
        SexFocus maybeSex ->
            case maybeSex of
                Just sex ->
                    let
                        graphFocusSex_ =
                            -- Add or Remove
                            if not (List.member sex graphFocusSex) then sex :: graphFocusSex else List.filter ((/=) sex) graphFocusSex
                    in
                    ( { rootModel 
                        | visualizer = { visualizerModel 
                            | graph = { graphModel | focusSex = graphFocusSex_ }
                        }
                      }
                    , Cmd.none
                    )
                Nothing ->
                    ( rootModel, Cmd.none )





-- VIEWS


view : RootModel -> Html Msg
view rootModel =
    let
        focusPlaces = rootModel.visualizer.graph.focusPlaces
        focusSex = rootModel.visualizer.graph.focusSex
        people = rootModel.visualizer.people

        filterList =
            [personFacesFilterByPlaces focusPlaces, personFacesFilterBySex focusSex ]
        allFilter =
            personFacesFilter filterList
        
        withoutSexFilter =
            personFacesFilter [personFacesFilterByPlaces focusPlaces]
        filteredPeople =
            List.map allFilter people
                |> List.filter ((/=) [])
        withoutSexFilteredPeople =
            List.map withoutSexFilter people
                |> List.filter ((/=) [])
    in
    div [ class "graph column", id "graph" ]
        [ h2 [ class "title" ] [ text "Graph" ]
        , div [ class "graph-container depression-container" ]
            [ div [ class "focus-places" ] 
                [ text "Focus: "
                , if focusPlaces == [] then
                    text "All"
                  else
                    div [ class "name-container" ] 
                        (List.map (\p -> Html.p [ onClick (RemoveFocusPlace p) ] [ text (p.name ++ " ×")]) focusPlaces)
                ]
            , sexView focusSex <| sexPer withoutSexFilteredPeople
            , ageView <| agePer people
            , barView filteredPeople rootModel
            ]
        ]


sexColors : List Sex -> Array Color
sexColors focusList =
    let
        focusList_ =
            if focusList == [] then [Male, Female, NotKnown] else focusList
    in
    Array.fromList
        [ rgba255 77 124 191 (if List.member Male focusList_  then 1 else 0.3)  -- MALE
        , rgba255 191 77 134 (if List.member Female focusList_  then 1 else 0.3) -- FEMALE
        , rgba255 220 220 220 (if List.member NotKnown focusList_  then 1 else 0.3) -- NotKnown
        , rgba255 220 220 220 1 -- Empty
        ]


sexView : List Sex -> List Float -> Html Msg
sexView focusSex valList =
    let
        ( valList_, labelVisible ) =
            if Maybe.withDefault 0 (List.maximum valList) > 0 then
                ( valList, True )

            else
                ( [ 0, 0, 0, 1 ], False )

        pieData =
            valList_ |> Shape.pie { defaultPieConfig | outerRadius = radius, sortingFn = nonSort }
    in
    div [ class "graph-svg sex" ]
        [ svg
            [ TypedSvg.Attributes.InPx.width pieW
            , TypedSvg.Attributes.InPx.height pieH
            ]
            [ annular Sex (sexColors focusSex) "Sex" pieData valList_ labelVisible ]
        ]


ageColors :  Array Color
ageColors =
    List.repeat 8
        [ rgba255 229 223 223 1
        , rgba255 190 190 190 1
        ]
        |> List.concat
        |> List.append [ rgba255 220 220 220 1 ]
        -- NotKnown
        |> Array.fromList


ageView : List Float -> Html Msg
ageView valList =
    let
        ( valList_, labelVisible ) =
            if Maybe.withDefault 0 (List.maximum valList) > 0 then
                ( valList, True )

            else
                ( List.map (\_ -> 0) (List.range 1 17)
                    -- 0~5 -> over 80
                    |> List.append [ 1 ]
                  -- empty
                , False
                )

        pieData =
            valList_ |> Shape.pie { defaultPieConfig | outerRadius = radius, sortingFn = nonSort }
    in
    div [ class "graph-svg age" ]
        [ svg
            [ TypedSvg.Attributes.InPx.width pieW
            , TypedSvg.Attributes.InPx.height pieH
            ]
            [ annular Age ageColors "Age" pieData valList_ labelVisible ]
        ]


-- PIE

pieW : Float
pieW =
    toFloat 250


pieH : Float
pieH =
    toFloat 250


radius : Float
radius =
    Basics.min (pieW / 2) pieH / 2 - 10


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


annular : GraphType -> Array Color -> String -> List Arc -> List Float -> Bool -> Svg Msg
annular graphType colorArray titleStr arcs valList labelVisible =
    let
        clickEvent index =
            case graphType of
                _ ->  -- TODO: Sex or Age
                    
                    let
                        sex =
                            case index of
                                0 ->
                                    Just Male

                                1 ->
                                    Just Female

                                2 ->
                                    Just NotKnown

                                _ ->
                                    Nothing
                    in
                    onClick (SexFocus sex)

        makeSlice index datum =
            Path.element (Shape.arc { datum | innerRadius = radius * 2 - 10 })
                [ fill <| Paint <| Maybe.withDefault Color.black <| Array.get index <| colorArray
                , clickEvent index
                ]

        makeLabels index ( datum, val ) =
            let
                ( x, y ) =
                    Shape.centroid { datum | innerRadius = radius * 2, outerRadius = radius * 2 + 10 }

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
                                head ++ " : " ++ String.fromInt (round ((val / List.sum valList) * 100)) ++ "%"

                            Age ->
                                String.fromInt (index * 5)
                                    ++ "~"
                                    ++ String.fromInt ((index + 1) * 5)
                                    ++ " : "
                                    ++ String.fromInt (round ((val / List.sum valList) * 100))
                                    ++ "%"

                    else
                        ""
            in
            labelText x y labelT
    in
    g [ transform [ Translate (pieW / 2) (pieW / 2) ] ]
        [ g []
            (List.indexedMap makeSlice <| arcs)
        , g [] (List.indexedMap makeLabels <| List.map2 Tuple.pair arcs valList)
        , title 0 0 titleStr
        ]


-- BAR

barW : Float
barW =
    toFloat 550


barH : Float
barH =
    toFloat 300


barPadding : Float
barPadding =
    toFloat 20


hourFormat : Time.Zone -> Time.Posix -> String
hourFormat timezone time =
    Time.Extra.posixToParts timezone time
        |> .hour
        |> String.fromInt


xScale : List (Time.Posix, Float) -> BandScale Time.Posix
xScale model =
    List.map Tuple.first model
        |> Scale.band { defaultBandConfig | paddingInner = 0.1, paddingOuter = 0.2 } ( 0, barW - 2 * barPadding )


yScale : Float -> Scale.ContinuousScale Float
yScale max =
    Scale.linear ( barH - 2 * barPadding, 0 ) ( 0, max )


xAxis : Time.Zone -> List (Time.Posix, Float) -> Svg msg
xAxis timezone model =
    Axis.bottom [] (Scale.toRenderable (hourFormat timezone) (xScale model))

yAxis : List (Time.Posix, Float) -> Svg msg
yAxis model =
    let
        maxVal =
            List.map Tuple.second model
                |> List.maximum
                |> Maybe.withDefault 0
    in
    Axis.left [] (yScale maxVal)


bar : Time.Zone -> BandScale Time.Posix -> Float -> (Time.Posix, Float) -> Svg msg
bar timezone scale max (date, value) =
    g [ TypedSvg.Attributes.class [ "bar" ] ]
        [ rect
            [ x <| Scale.convert scale date
            , y <| Scale.convert (yScale max) value
            , TypedSvg.Attributes.InPx.width <| Scale.bandwidth scale
            , TypedSvg.Attributes.InPx.height <| barH - Scale.convert (yScale max) value - 2 * barPadding
            , fill <| Paint <| rgba255 219 213 213 1
            , TypedSvg.Attributes.InPx.rx 6
            , TypedSvg.Attributes.InPx.ry 6
            ]
            []
        , text_
            [ x <| Scale.convert (Scale.toRenderable (hourFormat timezone) scale) date
            , y <| Scale.convert (yScale max) value - 5
            , textAnchor AnchorMiddle
            , fill <| Paint <| rgba255 70 70 70 1
            ]
            [ text <| String.fromFloat value ]
        ]


barGraph : Time.Zone -> List (Time.Posix, Float) -> Svg msg
barGraph timezone model =
    let
        maxVal =
            List.map Tuple.second model
                |> List.maximum
                |> Maybe.withDefault 0
    in
    svg [ viewBox 0 0 barW barH ]
        [ g [ transform [Translate (barPadding - 1) (barH - barPadding) ] ] [ xAxis timezone model ]
        , g [ transform [Translate (barPadding - 1) barPadding ] ] [ yAxis model ]
        , g
            [ transform [ Translate barPadding barPadding ], TypedSvg.Attributes.class [ "series" ] ]
            (List.map (bar timezone (xScale model) maxVal) model)
        ]


barView : List Person -> RootModel -> Html Msg
barView filteredPeople rootModel =
    let
        timezone = rootModel.settings.timezone
    in
    div [ class "graph-svg time" ]
        [ barGraph rootModel.settings.timezone (hourCount timezone filteredPeople) ]



-- SUBSCRIPTIONS

port placeClicked : (String -> msg) -> Sub msg

subscriptions : Sub Msg
subscriptions =
    Sub.batch [ placeClicked PlaceClicked ]



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
    List.map Basics.toFloat [ m, f, n ]


sexDetect : Person -> Sex
sexDetect person =
    let
        m =
            List.filter (\face -> face.sex == Male) person
                |> List.length

        f =
            List.filter (\face -> face.sex == Female) person
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
        averageList =
            List.map averageAge people
    in
    List.map
        (\u -> List.filter (\x -> x >= u - 5 && x < u) averageList |> List.length |> toFloat)
        (List.map (\i -> toFloat i * 5) (List.range 1 16))
        -- 0~4 -> 75~79
        |> List.append [ List.filter (\x -> x >= 80) averageList |> List.length |> toFloat ] -- over 80


averageAge : Person -> Float
averageAge person =
    let
        ageList =
            List.filterMap .age person

        average =
            List.sum ageList / toFloat (List.length ageList)
    in
    average




hourCount : Time.Zone -> List Person -> List (Time.Posix, Float)
hourCount timezone people =
    -- #TODO: なんか処理が冗長な気がするから, 寝不足でない時にリファクタリングする
    let
        times : List Int
        times =
            List.map (List.map .datetime) people
                |> List.concat
                |> List.map (Time.Extra.posixToParts timezone)
                |> List.map .hour
        
        hours =
            List.range 0 23
        
        counts =
            List.map (\hour -> (List.filter (\t -> t == hour) times) |> List.length) hours
    in
    List.map2 (\h c -> (hourToPosix timezone h, toFloat c)) hours counts



hourToPosix : Time.Zone -> Int -> Time.Posix
hourToPosix timezone hour =
    let
        unixzero = Time.millisToPosix 0
        unixzeroParts =
            Time.Extra.posixToParts timezone unixzero
                
    in
    Time.Extra.partsToPosix timezone {unixzeroParts | hour = hour }


personFacesFilter : List (Person -> List Face) -> Person -> List Face
personFacesFilter filterList person =
    case filterList of
        [] ->
            person
        
        filter :: tail ->
            personFacesFilter tail (filter person)


personFacesFilterByPlaces : List Place -> Person -> List Face
personFacesFilterByPlaces places person =
    case places of
        [] ->
            person

        _ ->
            (List.filter (\face -> List.member face.place places) person)

personFacesFilterBySex : List Sex -> Person -> List Face
personFacesFilterBySex sexlist person =
    case sexlist of 
        [] ->
            person
        
        _ ->
            List.filter (\face -> List.member face.sex sexlist) person


rgba255 : Int -> Int -> Int -> Float -> Color
rgba255 r g b a =
    Color.fromRgba { red = toFloat r / 255, green = toFloat g / 255, blue = toFloat b / 255, alpha = a }
