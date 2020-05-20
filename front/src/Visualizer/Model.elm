--  Copyright (C) 2020 Hiroki Takemura (kekeho)
--  
--  This file is part of Gingerbreadman.
--  
-- Gingerbreadman is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- Gingerbreadman is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with Gingerbreadman.  If not, see <http://www.gnu.org/licenses/>.


module Visualizer.Model exposing (..)

import Common.Data exposing (Place, datetimeDecoder, placeDecoder)
import Json.Decode as D exposing (Decoder)
import Json.Decode.Pipeline as P
import Time
import Tuple



-- MODEL INIT


modelInit : Model
modelInit =
    { controller = controllerModelInit
    , people = peopleInit
    , traffic = trafficInit
    }


controllerModelInit : ControllerModel
controllerModelInit =
    { places = []
    , selectedPlaces = []
    , placeSearchKeyword = ""
    , dateRange =
        { since = Time.millisToPosix 0
        , until = Time.millisToPosix 0
        }
    , inputDateRange =
        { since = "2000-01-01T00:00"
        , until = "2000-01-01T00:00"
        }
    , resultPlaces = []
    , resultDateRange =
        { since = Time.millisToPosix 0
        , until = Time.millisToPosix 0
        }
    , modalState = False
    }


peopleInit : List Person
peopleInit =
    []


trafficInit : List TrafficCount
trafficInit =
    []



-- MODELS


type alias Model =
    { controller : ControllerModel
    , people : List Person
    , traffic : TrafficModel
    }


type alias ControllerModel =
    { places : List Place
    , selectedPlaces : List Place
    , resultPlaces : List Place
    , placeSearchKeyword : String
    , dateRange : DateRange
    , inputDateRange : InputDateRange
    , resultDateRange : DateRange
    , modalState : Bool
    }


type alias TrafficModel =
    List TrafficCount


type alias Person =
    List Face


type alias Face =
    { id : String
    , imageId : String
    , imageUrl : String
    , faceImageB64 : String
    , faceLocation : FaceLocation
    , faceEncoding : List Float
    , place : Place
    , datetime : Time.Posix
    , sex : Sex
    -- , age : Maybe Float
    -- , emotion : Maybe Emotion
    }


type alias FaceLocation =
    { x : Int
    , y : Int
    , w : Int
    , h : Int
    }


type Sex
    = NotKnown
    | Male
    | Female


type Emotion
    = Smile
    | Anger
    | Contempt
    | Disgust
    | Fear
    | Happiness
    | Neutral
    | Sadness
    | Surprise



-- (a, b) : a -> b


type alias Traffic =
    ( Place, Place )


type alias TrafficCount =
    { traffic : Traffic
    , count : Int
    }


type alias DateRange =
    { since : Time.Posix
    , until : Time.Posix
    }


type alias InputDateRange =
    { since : String
    , until : String
    }



-- FUNCTIONS


sortWithTime : Person -> Person
sortWithTime person =
    let
        times =
            List.map
                (\f -> { posix = Time.posixToMillis f.datetime, face = f })
                person

        sortedFaces =
            List.sortBy .posix times
                |> List.map (\t -> t.face)
    in
    sortedFaces



-- JSON DECODERS


peopleDecoder : Decoder (List Person)
peopleDecoder =
    D.field "grouped_faces" (D.list personDecoder)


personDecoder : Decoder Person
personDecoder =
    D.list faceDecoder


faceDecoder : Decoder Face
faceDecoder =
    D.succeed Face
        |> P.required "id" D.string
        |> P.required "image_id" D.string
        |> P.required "image_url" D.string
        |> P.required "face_image" D.string
        |> P.required "face_location" faceLocationDecoder
        |> P.required "face_encoding" (D.list D.float)
        |> P.required "place" placeDecoder
        |> P.required "posix_millisec" datetimeDecoder
        |> P.required "sex" sexDecoder


faceLocationDecoder : Decoder FaceLocation
faceLocationDecoder =
    D.map4 FaceLocation
        (D.index 0 D.int)
        (D.index 1 D.int)
        (D.index 2 D.int)
        (D.index 3 D.int)


sexDecoder : Decoder Sex
sexDecoder =
    D.map intToSex D.int 


intToSex : Int -> Sex
intToSex val =
    case val of
        1 ->
            Male
        2 ->
            Female
        _ ->
            NotKnown
