import mycsv
import streams
import strutils
import times, strutils
import parsecsv

template benchmark*(benchmarkName: string, code: untyped) =
  block:
    let t0 = epochTime()
    code
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
    echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"


var lexer: mycsv.CSVLexer
lexer.file_path = "data/test.csv"
lexer.file_path = "data/fatData.csv"


benchmark "csvParse csvParse":
    var csv: CsvParser
    var arr = newSeq[seq[string]]()
    csv.open(lexer.file_path)
    while csv.readRow():
      arr.add csv.row

benchmark "csvParse baseVal":
    lexer.open newFileStream  lexer.file_path
    var data = lexer.processStream 
    echo data.len

benchmark "csvParse string":
    lexer.open newFileStream  lexer.file_path
    var data = lexer.processStreamAsString 
    echo data.len