from xmltree import `$`, attr
from htmlparser import parseHtml
import sequtils
import sugar
import asyncdispatch 
import os

import cligen
import httpclient
import nimquery

proc chunkArray[T](array: seq[T], size: int): seq[seq[T]] =
  var index = 0
  while index < array.len:
    result.add(array[index .. min(index + size - 1, array.len - 1)])
    index += size

proc download(links: seq[string], dir: string) {.async.} =
  let fileNames = links.map(x => x.split("/")[^1])
  let linkNamePairs = zip(links, filenames)
  for pair in linkNamePairs:
    let downloader = newAsyncHttpClient()
    asyncCheck downloader.downloadFile(pair[0], dir / pair[1])

proc downloadConcurrent(links: seq[string], maxConcurrentDls: int, dir: string) {.async.} =
  for chunk in chunkArray(links, maxConcurrentDls):
    await download(chunk, dir)

proc chandl(videosOnly = false, imagesOnly = false, maxConcurrentDls = 1, dir = getCurrentDir(), link: string) =
  if videosOnly and imagesOnly:
    quit("Please use either -v/--videosOnly or -i/--imagesOnly switch, but not both!")

  let client = newHttpClient()
  let media = client.getContent(link)
    .parseHtml
    .querySelectorAll("a.fileThumb")
    .map(x => x.attr("href"))
    
  # if not videosOnly:
  #   let images = media.filter(x => x.split(".")[^1] in ["jpg","jpeg","png","webp","gif"])
  #   waitFor downloadConcurrent(images, maxConcurrentDls, dir)

  # if not imagesOnly:
  #   let videos = media.filter(x => x.split(".")[^1] == "webm")
  #   waitFor downloadConcurrent(videos, maxConcurrentDls, dir)


when isMainModule:
  clCfg.hTabCols = @[clOptKeys, clDescrip]
  dispatch(
    chandl, 
    help = {
      "videosOnly" : "download videos only.",
      "imagesOnly" : "download images only.",
      "maxConcurrentDls": "set maximum parallel downloads. default: 1",
      "dir": "set download directory. default: current directory",
      "link": "thread link"}
  )
