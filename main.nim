import times
import strformat
import os
import ggplotnim


template benchmark*(benchmarkName: string, code: untyped) =
  block:
    let t0 = epochTime()
    code
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
    echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"

benchmark "ggplot readCsvTyped":
  var df = readCsvTyped("./data/fatData2.csv")
