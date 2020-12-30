import strutils
import sequtils
import math
import times
import os

template benchmark*(benchmarkName: string, code: untyped) =
  block:
    let t0 = epochTime()
    code
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
    echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"



var arr = newSeq[int]()
var count = 10_000_000

if paramCount() > 0:
    count = commandLineParams()[0].parseInt()

echo "adding 0 to ", count

for i in 0..count-1:
    arr.add i

echo "first:", arr[0], "\nlast:", arr[-0],"\nlength:", arr.len()

benchmark "foldl a + b":
    echo arr.foldl(a+b)

benchmark "sum":
    echo arr.sum()

benchmark "forloop":
    var sum = 0
    for i in arr:
        sum += i
    echo sum