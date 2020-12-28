import parsecsv
import times
import times, os, strutils
import re
import sequtils
import sugar

template benchmark*(benchmarkName: string, code: untyped) =
  block:
    let t0 = epochTime()
    code
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
    echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"

type 
  Test = object
    id: string
    name: string
    amount: int



