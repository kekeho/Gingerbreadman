module Upload.Model exposing (Model, modelInit)

import Common.Data
import Common.ErrorPanel
import File
import Http


-- MODEL INIT

modelInit : Model
modelInit =
    { places = Nothing
    , selectedPlace = Nothing
    , selectedImages = Nothing
    , newPlace = { name = "", latitude = 0.0, longitude = 0.0 }
    , placeSearchFiltered = []
    , placeSearchInput = ""
    , uploadedIndicator = Nothing
    }


-- MODEL
type alias Model =
    { places : Maybe (List Common.Data.Place)
    , selectedPlace : Maybe Common.Data.Place
    , newPlace : Common.Data.Place
    , selectedImages : Maybe (List File.File)
    , placeSearchInput : String
    , placeSearchFiltered : List Common.Data.Place
    , uploadedIndicator : Maybe String
    }
