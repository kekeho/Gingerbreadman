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
    , getPlacesError : Maybe Http.Error
    , uploadResult : Maybe (Result Http.Error ())
    , placeSearchInput : String
    , placeSearchFiltered : List Common.Data.Place
    , error : Common.ErrorPanel.Model
    }