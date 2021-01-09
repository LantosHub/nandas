import faststreams
import arraymancer
import strutils
import tables
import times

template benchmark*(benchmarkName: string, code: untyped) =
  block:
    let t0 = epochTime()
    code
    let elapsed = epochTime() - t0
    let elapsedStr = elapsed.formatFloat(format = ffDecimal, precision = 3)
    echo "CPU Time [", benchmarkName, "] ", elapsedStr, "s"

type
    BaseValKind = enum
        bvkInt, bvkFloat, bvkString, bvkNil, bvkInvalid
    BaseVal = object
        case kind*: BaseValKind
        of bvkInt:
            int_val*: int
        of bvkFloat:
            float_val*: float
        of bvkString:
            string_val*: string
        of bvkNil:
            nil
        of bvkInvalid:
            nil

    ColumnKind = enum
        ckInt, ckFloat, ckString, ckMixed
    Column = object
        case kind*: ColumnKind
        of ckInt:
            col_int*: Tensor[int]
        of ckFloat:
            col_float*: Tensor[float]
        of ckString:
            col_string*: Tensor[string]
        of ckMixed:
            col_mixed*: Tensor[BaseVal]

    DataFrame = object
        df: Table[string, Column]

    MyLexer = object
        s*: InputStream
        token*: BaseVal

proc getToken(m: var MyLexer): BaseVal =
    var isEscaped = false
    while m.s.readable():
        case m.s.peek.char
        of ',':
            if isEscaped:
                result.string_val.add m.s.read.char
            else:
                m.s.advance
                break
        of {'\c', '\L'}:
            m.s.advance
            if not isEscaped:
                break
        of '"':
            if isEscaped:
                if m.s.peek.char == '"':
                    result.string_val.add m.s.read.char
                elif  m.s.peek.char == ',':
                    m.s.advance
                    break
                else:
                    raise newException(IOError, "double Quotes must be escaped")
            else:
                isEscaped = true
                m.s.advance
        of '\0':
            break
        else:
            result.kind = bvkString
            result.string_val.add m.s.read.char
    m.token = result
        

proc read_csv(m: var  MyLexer): DataFrame =
    var mySeq = newSeq[BaseVal]()
    while m.s.readable():
        if m.getToken.kind notin { bvkInvalid }:
            mySeq.add m.token
        else: break
        
var isHandle =  faststreams.fileInput("../data/fatData1.csv")
# var isHandle =  faststreams.memFileInput("../data/fatData2.csv")

var myLexer = MyLexer(s: isHandle.s)
benchmark "readCSV":
    echo read_csv(myLexer)