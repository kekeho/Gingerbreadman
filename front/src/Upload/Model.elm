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
