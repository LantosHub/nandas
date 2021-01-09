import ggplotnim
import times, strutils

template benchmark*(benchmarkName: string, code: untyped) =
  block:
    let t0 = epochTime()
    code
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
    echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"


var fatData1: DataFrame
var fatData2: DataFrame
benchmark "read fatData1":
    fatData1 = readCsvTyped("data/fatData1.csv")

benchmark "read fatData2":
    fatData2 = readCsvTyped("data/fatData2.csv")

benchmark "read fatData1":
    echo fatData1["key0"].len
    echo fatData2["key1"].len

# benchmark "match keys":
#     fatData1[""]