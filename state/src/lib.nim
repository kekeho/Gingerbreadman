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

import asyncdispatch
import sequtils
import strutils
import os
import sugar


type
    CoreState = object
        cpuid: int
        user: float32
        nice: float32
        system: float32
        idle: float32


type
    RawCoreState = object
        cpuid: int  # -1 means total
        user: int
        nice: int
        system: int
        idle: int


type
    State* = object
        cpuStateList: seq[CoreState]
        error: string



proc getState*(): Future[State] =
    let resultState = newFuture[State]("result")

    # Open /proc/stat
    var
        cpuStateContentBefore: File
        cpuStateContentAfter: File    
    try:
        cpuStateContentBefore = open("/proc/stat", fmRead)
        cpuStateContentAfter = open("/proc/stat", fmRead)
    except IOError:
        resultState.complete(State(cpuStateList: @[], error:"Can't open /proc/stat"))
        return resultState

    var
        rawStateListBefore: seq[RawCoreState]
        rawStateListAfter: seq[RawCoreState]

    # Read cpuStateContentBefore
    for line in cpuStateContentBefore.readAll().split("\n"):
        let columns = line.split(" ").filter(x => x != "")
        if columns == [] or columns[0][0..2] != "cpu":
            continue

        let cpuid = if columns[0] == "cpu": -1 else: ($(columns[0][3])).parseInt
        let rawstate = RawCoreState(
            cpuid: cpuid, user: columns[1].parseInt, nice: columns[2].parseInt,
            system: columns[3].parseInt, idle: columns[4].parseInt
        )
        rawStateListBefore.insert(rawstate)
    
    sleep(100)
    
    # Read cpuStateContentAfter
    for line in cpuStateContentAfter.readAll().split("\n"):
        let columns = line.split(" ").filter(x => x != "")
        if columns == [] or columns[0][0..2] != "cpu":
            continue

        let cpuid = if columns[0] == "cpu": -1 else: ($(columns[0][3])).parseInt
        let rawstate = RawCoreState(
            cpuid: cpuid, user: columns[1].parseInt, nice: columns[2].parseInt,
            system: columns[3].parseInt, idle: columns[4].parseInt
        )
        rawStateListAfter.insert(rawstate)
    
    # Get diff
    var state = State(cpuStateList: @[], error: "")
    for (before, after) in zip(rawStateListBefore, rawStateListAfter):
        let
            sumTime = (after.user - before.user) + (after.nice - before.nice) + (after.system - before.system) + (after.idle - before.idle)
            userPer = (after.user - before.user) / sumTime * 100
            nicePer = (after.nice - before.nice) / sumTime * 100
            systemPer = (after.system - before.system) / sumTime * 100
            idlePer = (after.idle - before.idle) / sumTime * 100
        state.cpuStateList.insert(CoreState(cpuid: after.cpuid, user: userPer, nice: nicePer, system: systemPer, idle: idlePer))


    resultState.complete(state)
    return resultState
