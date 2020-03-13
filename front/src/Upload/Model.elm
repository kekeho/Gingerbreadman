module Upload.Model exposing (Model)


import Http
import File

import Common.ErrorPanel
import Common.Data

type alias Model =
    { places : Maybe (List Common.Data.Place)
    , selectedPlace : Maybe Common.Data.Place
    , newPlace : Common.Data.Place
    , selectedImages : Maybe (List File.File)
    , placeSearchInput : String
    , placeSearchFiltered : List Common.Data.Place
    , uploadedIndicator : Maybe String
    }