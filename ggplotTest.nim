import ggplotnim
import tables

import times, strutils

template benchmark*(benchmarkName: string, code: untyped) =
  block:
    let t0 = epochTime()
    code
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
    echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"

var csvData: OrderedTable[system.string, seq[string]]
var df: DataFrame
benchmark "ggplot readCsv":
  csvData = "data/fatData.csv".readCsv()

benchmark "ggplot csv.toDf":
  df =  csvData.toDf()

benchmark "sum":
  echo df["value"].toTensor(float).sum()
