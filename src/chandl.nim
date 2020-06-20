import cligen;

proc chandl(videosOnly=false,imagesOnly=false,maxConcurrentDls=1,dir="./") =
  echo "hello world"

when isMainModule:
  dispatch(
    chandl, 
    help = {
      "videosOnly" : "download videos only.",
      "imagesOnly" : "download images only.",
      "maxConcurrentDls": "set maximum parallel downloads. Default: 1",
      "dir": "set download directory. Default: ./"}
  )
