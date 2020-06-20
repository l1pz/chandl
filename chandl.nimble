# Package

version       = "0.1.0"
author        = "l1pz"
description   = "4chan thread images/videos downloader"
license       = "Unlicense"
srcDir        = "src"
bin           = @["chandl"]
binDir =      "bin"



# Dependencies

requires "nim >= 1.2.0"
requires "cligen >= 1.0.0"
requires "nimquery >= 1.2.2"
requires "progress >= 1.1.1"