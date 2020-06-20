import cligen;

proc chandl(videosOnly=false,imagesOnly=false,maxConcurrentDls=1,dir="./", link: string) =
  if videosOnly and imagesOnly:
    quit("Please use either videosOnly or imagesOnly switch, but not both!")
  

when isMainModule:
  dispatch(
    chandl, 
    help = {
      "videosOnly" : "download videos only.",
      "imagesOnly" : "download images only.",
      "maxConcurrentDls": "set maximum parallel downloads. Default: 1",
      "dir": "set download directory. Default: ./",
      "link": "thread link"}
  )
