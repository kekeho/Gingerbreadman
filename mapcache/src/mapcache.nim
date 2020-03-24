# Copyright (c) 2020 Hiroki Takemura (kekeho)
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

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
