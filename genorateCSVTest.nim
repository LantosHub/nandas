import tables
import md5
import random
import times, os, strutils
import baseTypes
import csvtools

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



var objArr1: seq[MyObject1] = @[]
var objArr2: seq[MyObject2] = @[]

var rowCount = 1_000_000
benchmark "makeFatData":
    for i in 0..rowCount:
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

benchmark "update":
    for i in 0..objArr1.len-1:
        objArr1[i].amount = objArr1[i].amount + 1.0



var df1 = initTable[string, Table[string, Base_Type]]()
var df2 = initTable[string, Table[string, Base_Type]]()

benchmark "makeFatDataTable":
    for i in 0..rowCount:
        var key = $toMD5($i)
        df1[$i] = {
            "key0": Base_Type(kind: btk_string, string_val: key),
            "amount": Base_Type(kind: btk_float, float_val: random.rand(100_000.00))
        }.toTable()
        if i.mod(3) == 0:
            df2[$i] = {
                "key1": Base_Type(kind: btk_string, string_val: "key"),
                "key2": Base_Type(kind: btk_string, string_val: "key"),
                "key3": Base_Type(kind: btk_string, string_val: key),
                "spent": Base_Type(kind: btk_float, float_val: random.rand(100_000.00))
            }.toTable()
        elif i.mod(2) == 0:
            df2[$i] = {
                "key1": Base_Type(kind: btk_string, string_val: "key"),
                "key2": Base_Type(kind: btk_string, string_val: key),
                "key3": Base_Type(kind: btk_string, string_val: "key"),
                "spent": Base_Type(kind: btk_float, float_val: random.rand(100_000.00))
            }.toTable()
        else:
            df2[$i] = {
                "key1": Base_Type(kind: btk_string, string_val: key),
                "key2": Base_Type(kind: btk_string, string_val: "key"),
                "key3": Base_Type(kind: btk_string, string_val: "key"),
                "spent": Base_Type(kind: btk_float, float_val: random.rand(100_000.00))
            }.toTable()

benchmark "update":
    for row in df1.mvalues():
        row["amount"].float_val = row["amount"].float_val + 1

benchmark "writeCSV":
    objArr2.writeToCsv("data/fatData.csv")