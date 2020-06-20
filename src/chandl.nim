from xmltree import `$`, attr
from htmlparser import parseHtml
import sequtils
import sugar
import asyncdispatch 
import os
import times

import cligen
import httpclient
import nimquery
import progress

type ProgressBar = ref progress.ProgressBar

proc chunkArray[T](array: seq[T], size: int): seq[seq[T]] =
  var index = 0
  while index < array.len:
    result.add(array[index .. min(index + size - 1, array.len - 1)])
    index += size

proc download(link: string, path: string) {.async.} =
  let downloader = newAsyncHttpClient()
  await downloader.downloadFile(link, path)
  downloader.close

proc checkDownloads(downloads: seq[Future[void]], bar: ProgressBar): Future[void] =
  var retFuture = newFuture[void]("downloadsCheck")
  var completedDownloads = 0

  for download in downloads:
    download.addCallback proc (dl: Future[void]) =
      completedDownloads += 1
      bar[].increment()
      if not retFuture.finished:
        if dl.failed:
          retFuture.fail(dl.error)
        else:
          if completedDownloads == downloads.len:
            retFuture.complete()

  if downloads.len == 0:
    retFuture.complete()
  
  return retFuture

proc downloadConcurrent(links: seq[string], parallelDlLimit: int, dir: string) {.async.} =
  let chunks = if parallelDlLimit != 0:
      chunkArray(links, parallelDlLimit)
    else:
      @[links]

  var bar: ProgressBar
  bar = new progress.ProgressBar
  bar[] = newProgressBar(links.len)
  bar[].start()
  
  for chunk in chunks:
    let fileNames = chunk.map(x => x.split("/")[^1])
    let linkNamePairs = zip(chunk, filenames)
    var downloads = newSeqOfCap[Future[void]](parallelDlLimit)
    for pair in linkNamePairs:
      let link = "https:" & pair[0]
      let path = dir / pair[1]
      downloads.add(download(link, path))
    await checkDownloads(downloads, bar)

  bar[].finish()

proc chandl(videosOnly = false, imagesOnly = false, parallelDlLimit = 0, dir = getCurrentDir(), link: string) =
  if videosOnly and imagesOnly:
    quit("Please use either -v/--videosOnly or -i/--imagesOnly switch, but not both!")

  let client = newHttpClient()
  let media = client.getContent(link)
    .parseHtml
    .querySelectorAll("a.fileThumb")
    .map(x => x.attr("href"))

  let t0 = cpuTime()
  echo "downloading images"  
  if not videosOnly:
     let images = media.filter(x => x.split(".")[^1] in ["jpg","jpeg","png","webp","gif"])
     waitFor downloadConcurrent(images, parallelDlLimit, dir)

  echo "downloading videos"  
  if not imagesOnly:
     let videos = media.filter(x => x.split(".")[^1] == "webm")
     waitFor downloadConcurrent(videos, parallelDlLimit, dir)

  let t1 = cpuTime()
  echo("finished in " & $(t1-t0) & " seconds")


when isMainModule:
  clCfg.hTabCols = @[clOptKeys, clDescrip]
  dispatch(
    chandl, 
    help = {
      "videosOnly" : "download videos only.",
      "imagesOnly" : "download images only.",
      "parallelDlLimit": "set a limit for parallel downloads. default: 0 - means no limit",
      "dir": "set download directory. default: current directory",
      "link": "thread link - REQUIRED"}
  )
