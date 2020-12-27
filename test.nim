import parsecsv
import times
import times, os, strutils
import re

template benchmark*(benchmarkName: string, code: untyped) =
  block:
    let t0 = epochTime()
    code
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
    echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"



var filePath = "data/Machine_readable_file_bdcsf2020sepBig.csv"

benchmark "readFile":
  discard readFile(filePath)

benchmark "split readFile":
  echo readFile(filePath).splitLines().len


benchmark "split Readfile RE":
  var abc =  readFile(filePath).split(re"""(?:^|,)(?=[^"]|(")?)"?((?(1)[^"]*|[^,"]*))"?(?=,|$)""")
  echo abc.len

benchmark "csvReader":
    var csvParser: CsvParser
    csvParser.open(filePath)
    csvParser.readHeaderRow()

    while csvParser.readRow():
      for header in csvParser.headers:
          discard