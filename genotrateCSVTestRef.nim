import md5
import random
import times, os, strutils

template benchmark*(benchmarkName: string, code: untyped) =
  block:
    let t0 = epochTime()
    code
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
    echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"


type
    MyObject1 = ref object
        key0: string
        amount: float
    MyObject2 =ref object
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


# var t1 = initOrderedTable[string, MyObject2]()
# var t2 = initOrderedTable[string, MyObject2]()
# var t3 = initOrderedTable[string, MyObject2]()

# benchmark "find key":
#     for obj in objArr2:
#         t1[obj.key1] = obj
#         t1[obj.key2] = obj
#         t1[obj.key3] = obj

#     for obj in objArr1:
#         if t1.hasKey(obj.key0):
#             t1[obj.key0].matched_on = "key1"
#             t1[obj.key0].amount_obj1 = obj.amount
#         if t2.hasKey(obj.key0):
#             t2[obj.key0].matched_on = "key2"
#             t2[obj.key0].amount_obj1 = obj.amount
#         if t3.hasKey(obj.key0):
#             t3[obj.key0].matched_on = "key3"
#             t3[obj.key0].amount_obj1 = obj.amount

#     echo objArr2[0][]

