import mycsv
import streams
import strutils
import times, strutils

template benchmark*(benchmarkName: string, code: untyped) =
  block:
    let t0 = epochTime()
    code
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
    echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"


var lexer: mycsv.CSVLexer
lexer.file_path = "data/test.csv"
lexer.file_path = "data/Machine_readable_file_bdcsf2020sepBig.csv"

benchmark "csvParse":
    lexer.open newFileStream  lexer.file_path
    var data = lexer.processStream 
    echo data.len
benchmark "csvParse":
    lexer.open newFileStream  lexer.file_path
    var data = lexer.processStreamAsString 
    echo data.len