module Person exposing (Person, FaceLocation, Place, Gender, Emotion)


-- MODEL TYPES

type alias Person =
    { id : String
    , imageId : String
    , imageUrl : String
    , faceLocation : FaceLocation
    , faceEncoding : List Float
    , place : Place
    , gender : Maybe Gender
    , age : Maybe Float
    , emotion : Maybe Emotion
    }

type alias FaceLocation =
    { x : Int
    , y : Int
    , w : Int
    , h : Int
    }

type alias Place =
    { name : String
    , latitude : Float
    , longitude : Float
    }

type Gender
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