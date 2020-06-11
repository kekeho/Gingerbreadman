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


import strutils


type CPUCoreInfo = object
    id: int
    model: string


proc getCPUInfo*(cpuinfoFile: string = "/proc/cpuinfo") : seq[CPUCoreInfo] =
    var coreList : seq[CPUCoreInfo]
    var lines : seq[string]
    try:
        block:
            var f : File = open(cpuinfoFile, FileMode.fmRead)
            defer:
                close(f)

            while not f.endOfFile:
                lines.add(f.readLine)

    except IOError:
        return @[]

    var core : CPUCoreInfo
    for line in lines:
        if line == "":  # separator
            coreList.add(core)
            continue
        
        if "processor" in line:
            let id = line[line.find(":")+1..line.len-1].replace(" ", "").parseInt
            core.id = id
        
        if "model name" in line:
            let modelName = line[line.find(':')+1..line.len-1]
            core.model = modelName
    
    return coreList
