# Copyright (c) 2020 Hiroki Takemura (kekeho)
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

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