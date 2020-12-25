import lexbase
import streams
import strformat
import strutils
import baseTypes

when isMainModule:
    import os

type
    CSV_Token* = enum
        tk_invalid
        tk_string
        tk_int
        tk_float
        tk_new_line
        tk_end_of_input

    Lexer* = object of BaseLexer
        kind*: CSV_Token
        token*: string
        error*: string
        file_path*: string


proc open*(lexer: var Lexer, input: Stream) =
    lexbase.open(lexer, input)
    lexer.kind = tk_invalid
    lexer.error = ""

proc skip*(lexer: var Lexer) =
    lexer.bufpos.inc

proc get_char*(lexer: Lexer): char =
    lexer.buf[lexer.bufpos]

proc consume*(lexer: var Lexer): char =
    result = lexer.get_char
    lexer.skip

proc set_error*(lexer: var Lexer, error_message: string) =
    lexer.kind = tk_invalid
    if lexer.error.len == 0:
        lexer.error = &"{lexer.file_path}({lexer.getColNumber( lexer.bufpos )+1},{lexer.lineNumber}) {error_message} \n {lexer.get_char} {lexer.getCurrentLine}"

proc has_error*(lexer: Lexer): bool =
    lexer.error.len > 0



proc handle_value(lexer: var Lexer) =
    var isEscaped = false
    lexer.kind = tk_int
    if lexer.get_char == '"':
        lexer.kind = tk_string
        isEscaped = true
        lexer.skip
    while true:
        case lexer.get_char:
        of ',':
            if isEscaped:
                lexer.token.add lexer.consume
            else:
                if lexer.token == "":
                    lexer.kind = tk_string
                lexer.skip
                break
        of '"':
            lexer.skip
            if lexer.get_char == '"':
                lexer.token.add lexer.consume
            elif lexer.get_char == ',':
                lexer.skip
                break
            else:
                lexer.set_error(""" double(") quotes need to be escaped with "" or \"""")
                break
        of '0'..'9':
            lexer.token.add lexer.consume
        of '.':
            if lexer.kind == tk_int:
                lexer.kind = tk_float
            elif lexer.kind == tk_float:
                lexer.kind = tk_string
            lexer.token.add lexer.consume
        else:
            lexer.kind = tk_string
            lexer.token.add lexer.consume

    

proc get_token(lexer: var Lexer): CSV_Token =
    lexer.token = ""
    lexer.kind = tk_invalid
    case lexer.get_char:
    of lexbase.NewLines: 
        lexer.kind = tk_new_line
        lexer.skip
    of EndOfFile:
        lexer.kind = tk_end_of_input
    else: lexer.handle_value
    # echo lexer.token, " ",lexer.kind
    return lexer.kind


proc processStream(lexer: var Lexer): seq[seq[Base_Type]] =
    try:
        var tempRow: seq[Base_Type] = @[]
        while lexer.get_token notin { tk_invalid }:
            case lexer.kind:
            of tk_end_of_input:
                break
            of tk_new_line:
                result.add tempRow
            of tk_int:
                tempRow.add Base_Type(kind:btk_int, int_val: parseInt(lexer.token))
            of tk_float:
                tempRow.add Base_Type(kind:btk_float, float_val: parseFloat(lexer.token))
            of tk_string:
                tempRow.add Base_Type(kind:btk_string, string_val: lexer.token)
            else:
                lexer.kind = tk_invalid
        if lexer.has_error:
            echo lexer.error
            
    except:
        lexer.set_error(getCurrentExceptionMsg())

when isMainModule:
    proc main() =
        var lexer: Lexer
        # if paramCount() < 1:
        #     echo "Waiting STDIN..."
        #     lexer.open newFileStream stdin
        # else:
        #     lexer.file_path = absolute_path(paramStr 1)
        #     echo "reading file ", lexer.file_path
        #     let temp_file_stream = newFileStream lexer.file_path
        #     lexer.open temp_file_stream
        lexer.file_path = "data/Machine_readable_file_bdcsf2020sep.csv"
        lexer.open newFileStream  lexer.file_path
        var data = lexer.processStream 
        echo($data[data.len-1], " ", data.len, " ", data[data.len-1].len)
    main()
