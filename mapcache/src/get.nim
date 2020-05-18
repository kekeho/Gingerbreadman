# Copyright (C) 2020 Hiroki Takemura (kekeho)
# 
# This file is part of Gingerbreadman.
# 
# Gingerbreadman is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Gingerbreadman is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Gingerbreadman.  If not, see <http://www.gnu.org/licenses/>.


import httpclient
import strformat
import os
import asyncdispatch


proc downloadOSMTile*(s: string, z, x, y : int): Future[void] =
    let
        c = newAsyncHttpClient()
        url = fmt"https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        saveFileDir = fmt"{getCurrentDir()}/cache/{s}/{z}/{x}"
        saveFilename = fmt"{saveFileDir}/{y}.png"
    
    defer:
        c.close()
    
    if not os.existsDir(saveFileDir):
        os.createDir(saveFileDir)

    echo fmt"{url} -> {saveFilename}"
    
    c.downloadFile(url, saveFilename)


proc getOSMTile*(s: string, z, x, y: int): TaintedString =
    let
        filename = fmt"{getCurrentDir()}/cache/{s}/{z}/{x}/{y}.png"
    
    if not os.existsFile(filename):
        waitFor downloadOSMTile(s, z, x, y)
    
    return open(filename).readAll()