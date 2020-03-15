module Upload.Model exposing (Model)

import Common.Data
import Common.ErrorPanel
import File
import Http


type alias Model =
    { places : Maybe (List Common.Data.Place)
    , selectedPlace : Maybe Common.Data.Place
    , newPlace : Common.Data.Place
    , selectedImages : Maybe (List File.File)
    , placeSearchInput : String
    , placeSearchFiltered : List Common.Data.Place
    , uploadedIndicator : Maybe String
    }
