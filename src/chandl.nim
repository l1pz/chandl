from xmltree import `$`, attr
from htmlparser import parseHtml
import sequtils
import sugar
import strformat
import asyncdispatch 

import cligen
import httpclient
import nimquery

template chunkArray(array: seq[untyped], size: int): seq[seq[untyped]] =
  var index = 0
  while index < array.len:
    result.add(array[index .. size + index])
    index += size

proc download(links: seq[string]) {.async.} =
  let downloader = newAsyncHttpClient()
  let fileNames = links.map(x => x.split("/")[^1])
  let linkNamePairs = zip(links, filenames)
  for pair in linkNamePairs:
    asyncCheck downloader.downloadFile(pair[0], pair[1])

proc chandl(videosOnly=false,imagesOnly=false,maxConcurrentDls=1,dir="./", link: string) =
  if videosOnly and imagesOnly:
    quit("Please use either -v/--videosOnly or -i/--imagesOnly switch, but not both!")

  let client = newHttpClient()
  let media = client.getContent(link)
    .parseHtml
    .querySelectorAll("a.fileThumb")
    .map(x => x.attr("href"))
    
  let images = media.filter(x => x.split(".")[^1] in ["jpg","jpeg","png","webp","gif"])
  let videos = media.filter(x => x.split(".")[^1] == "webm")

  echo &"Images ({images.len}):"
  for image in images:
    echo image

  echo &"Videos ({videos.len}):"
  for video in videos:
    echo video
  


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
