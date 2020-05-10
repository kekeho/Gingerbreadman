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


import asynchttpserver, asyncdispatch
import marshal
import lib

var server = newAsyncHttpServer()

proc callback(req: Request) {.async.} =
    let stateData = await lib.getState()
    let headers = newHttpHeaders([("Content-Type", "application/json")])
    await req.respond(Http200, $$stateData, headers)

when isMainModule:
  waitFor server.serve(Port(10999), callback, "0.0.0.0")