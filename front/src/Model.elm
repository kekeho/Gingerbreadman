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


module Model exposing (..)

import Browser.Navigation as Nav
import Common.ErrorPanel as ErrorPanel
import Common.Settings
import Upload.Model
import Url
import Url.Parser
import Visualizer.Model



-- MODEL


type alias RootModel =
    { key : Nav.Key
    , url : Url.Url
    , route : Route
    , errorList : ErrorPanel.Model
    , visualizer : Visualizer.Model.Model
    , upload : Upload.Model.Model
    , settings : Common.Settings.Model
    }


type Route
    = VisualizerPage
    | UploadPage
