import memfiles
import times
import strutils

template benchmark*(benchmarkName: string, code: untyped) =
  block:
    let t0 = epochTime()
    try:
        code
    except:
        raise getCurrentException()
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
    echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"


var mf: MemFile
var file = system.open("data/fatData3.csv", fmWrite)
var data: cstring

# os caches the files, clear cache on linux with
# sync; echo 3 > /proc/sys/vm/drop_caches

benchmark "read mf":
    mf = memfiles.open("./data/fatData2.csv")
    # file is not read untill mem is accessed it seems
    data = cast[cstring](mf.mem)

benchmark "write file":
    file.write(data)