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


import asynchttpserver
import httpclient
import asyncdispatch
import uri
import strformat
import strutils

import get


var server = newAsyncHttpServer()
proc cb(req: Request) {.async.} =
    let
        pathList = req.url.path.split('/')

    var 
        s : string 
        z, x, y : int
    
    try:
        s = pathList[2]
        z = pathList[3].parseInt
        x = pathList[4].parseInt
        y = pathList[5].parseInt
    except IndexError, ValueError:
        let header = newHttpHeaders([("Content-Type", "plain/text")])
        await respond(req, Http400, "400 Bad request\n{req.url}", header)
    
    try:
        let
            content = getOSMTile(s, z, x, y)
            header = newHttpHeaders([("Content-Type", "image/png")])
        await respond(req, Http200, content, header)
    except HttpRequestError:
        let header = newHttpHeaders([("Content-Type", "plain/text")])
        await respond(req, Http404, "404 Not Found", header)
        
        


when isMainModule:
    waitFor server.serve(Port(8000), cb)
