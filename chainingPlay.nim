import times
import strutils
import sequtils


# Hint: chainingPlay  [Exec]
# 100000001
# CPU Time [forloop i] 0.251s
# 100000001
# CPU Time [itter i] 0.318s
# 100020001
# CPU Time [forloop i,j] 0.253s
# 100020001
# CPU Time [itter.toSeq.items i,j] 1.262s
# 100020001
# CPU Time [itter: itter: int{.closure} i,j] 1.563s


template benchmark*(benchmarkName: string, code: untyped) =
  block:
    let t0 = epochTime()
    code
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
    echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"

var count = 10_000

iterator bigItter(): int=
    for i in 0..count*count:
        yield i


# using to seq items
iterator itter(): int =
    for i in 0..count:
        yield i

iterator itterToSeq: seq[int] =
    for i in 0..count:
        yield itter.toSeq

# closure

iterator itterClosure(): int {.closure.}=
    for i in 0..count:
        yield i

iterator ItterItterClosure: iterator: int =
    for i in 0..count:
        yield itterClosure

benchmark "forloop i":
    var sum = 0
    for i in 0..count*count:
        sum.inc
    echo sum


benchmark "itter i":
    var sum = 0
    for i in bigItter():
        sum.inc
    echo sum

benchmark "forloop i,j":
    var sum = 0
    for i in 0..count:
        for j in 0..count:
            sum.inc
    echo sum

benchmark "itter.toSeq.items i,j":
    var sum = 0
    for vitter in itterToSeq():
        for i in vitter.items:
            sum.inc
    echo sum

benchmark "itter: itter: int{.closure} i,j":
    var sum = 0
    for vitterClosure in ItterItterClosure():
        for i in vitterClosure:
            sum.inc
    echo sum