import md5
import random
import tables
import times, os, strutils

template benchmark*(benchmarkName: string, code: untyped) =
  block:
    let t0 = epochTime()
    code
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
    echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"


type
    MyObject1 = object
        key0: string
        amount: float
    MyObject2 = object
        key1: string
        key2: string
        key3: string
        value: float
        matched_on: string
        amount_obj1: float




var objArr1: seq[MyObject1] = @[]
var objArr2: seq[MyObject2] = @[]

var rowCount = 100_000

if paramCount() > 0:
    rowCount = commandLineParams()[0].parseInt()

echo "rowCount:",rowCount

benchmark "makeFatData":
    for i in 0..rowCount-1:
        var key = $toMD5($i)
        objArr1.add MyObject1(
            key0: key,
            amount: random.rand(100_000.00)
        )
        if i.mod(3) == 0:
            objArr2.add MyObject2(
                key1: "key",
                key2: "key",
                key3: key,
                value: random.rand(100_000.00)
            )
        elif i.mod(2) == 0:
            objArr2.add MyObject2(
                key1: "key",
                key2: key,
                key3: "key",
                value: random.rand(100_000.00)
            )
        else:
            objArr2.add MyObject2(
                key1: key,
                key2: "key",
                key3: "key",
                value: random.rand(100_000.00)
            )
            
var t1 = initOrderedTable[string, int]()
var t2 = initOrderedTable[string, int]()
var t3 = initOrderedTable[string, int]()

benchmark "find key":
    for i in 0..objArr2.len-1:
        t1[objArr2[i].key1] = i
        t1[objArr2[i].key2] = i
        t1[objArr2[i].key3] = i

    for i in 0..objArr1.len-1:
        if t1.hasKey(objArr1[i].key0):
            objArr2[t1[objArr1[i].key0]].matched_on  = "key1"
            objArr2[t1[objArr1[i].key0]].amount_obj1  = objArr1[i].amount
        if t2.hasKey(objArr1[i].key0):
            objArr2[t1[objArr1[i].key0]].matched_on  = "key2"
            objArr2[t1[objArr1[i].key0]].amount_obj1  = objArr1[i].amount
        if t3.hasKey(objArr1[i].key0):
            objArr2[t1[objArr1[i].key0]].matched_on  = "key3"
            objArr2[t1[objArr1[i].key0]].amount_obj1  = objArr1[i].amount
    echo objArr2[0]