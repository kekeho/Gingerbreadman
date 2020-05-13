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


import asynchttpserver, httpclient, httpcore, asyncdispatch
import marshal
import os
import sequtils
import sugar
import json
import strformat
import lib

var server = newAsyncHttpServer()

proc worker_callback(req: Request) {.async.} =
    let stateData = await lib.getState()
    let headers = newHttpHeaders([("Content-Type", "application/json")])
    await req.respond(Http200, $$stateData, headers)


proc master_callback(req: Request) {.async.} =
    let workersFile = open(".workers_tmp.json", fmReadWrite)
    var connectedWorkersAddress: seq[string]
    try:
        connectedWorkersAddress = to[seq[string]](workersFile.readAll())
    except JsonParsingError:
        workersFile.write("[]")

    if req.reqMethod == HttpPost:  # New connection
        # Regist workers
        let address = req.body
        connectedWorkersAddress.insert(address)
        workersFile.write($$connectedWorkersAddress)
        echo fmt"Connected from {address}"
        let headers = newHttpHeaders([("Content-Type", "text/plain")])
        await req.respond(HTTP200, "REGISTERED", headers)
    else:
        # Collect workers state
        var states: seq[WorkerState] = @[]
        var newConnectedWorkersAddress = connectedWorkersAddress
        for worker in connectedWorkersAddress:
            try:
                states.insert(await getStateOverNetwork(worker))
            except HttpRequestError:  # Worker disconnected
                connectedWorkersAddress = newConnectedWorkersAddress.filter(x =>  x != worker)  # Remove worker from list
        
        workersFile.write($$connectedWorkersAddress)
        let headers = newHttpHeaders([("Content-Type", "application/json")])
        await req.respond(HTTP200, $$states, headers)


when isMainModule:
    let callback = if paramCount() >= 1 and commandLineParams()[0] == "worker": worker_callback else: master_callback

    if callback == worker_callback:
        # Regist self in master
        let connected = false
        while not connected:
            let client = newAsyncHttpClient()
            let host = getEnv("NGINX_HOST")
            let resp = waitFor client.post(fmt"http://{host}:10999")
            echo resp.status
            sleep(100)

    waitFor server.serve(Port(10999), callback, "0.0.0.0")
