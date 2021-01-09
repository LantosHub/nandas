import times
import strutils
import ggplotnim
import memfiles
import parsecsv

template benchmark*(benchmarkName: string, code: untyped) =
  block:
    let t0 = epochTime()
    code
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
    echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"

var filePath = "data/fatData2.csv"

benchmark "nim lines":
  var data = newSeq[string]()
  for line in filePath.lines():
    data.add line

benchmark "nim parsecsv":
  var csvParser: CsvParser
  csvParser.open(filePath)
  csvParser.readHeaderRow()
  while csvParser.readRow():
    discard



benchmark "nim csvtools":
  var data = readCsv(filePath)

benchmark "ggplot readCsvTyped":
  var df = readCsvTyped(filePath)

benchmark "nim memfile line count":
  var mf = memfiles.open(filePath)
  var lineCount = 0
  for slices in mf.memSlices:
    lineCount.inc

benchmark "nim memfile castStr":
  var mf = memfiles.open(filePath)
  var buff =  cast[cstring](mf.mem)
  echo "Length of membuff:", buff.len

iterator parse(mf: MemFile): MemSlice {.inline.} =
  var pos = 0
  var buff =  cast[cstring](mf.mem)
  var ms: MemSlice
  ms.data = mf.mem
  while pos < mf.size:
    case buff[pos]
    of ',':
      yield ms
      pos.inc
      ms.size = 0
      ms.data = buff[pos].addr
    of '\x00':
      yield ms
      break
    else:
      ms.size.inc
      pos.inc

iterator values(mf: MemFile): string = 
  var buff = TaintedString(newStringOfCap(80))
  for ms in mf.parse():
    setLen(buff, ms.size)
    copyMem(buff[0].addr, ms.data, ms.size)
    yield buff

benchmark "nim memfile parse":
  var mf = memfiles.open(filePath)
  for value in mf.values():
    discard

