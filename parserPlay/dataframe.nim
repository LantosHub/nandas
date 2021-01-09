import lexbase
import streams
import strformat
import strutils
import baseTypes
import ggplotnim

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

    CSVLexer* = object of BaseLexer
        kind*: CSV_Token
        token*: string
        error*: string
        file_path*: string


proc open*(lexer: var CSVLexer, input: Stream) =
    lexbase.open(lexer, input)
    lexer.kind = tk_invalid
    lexer.error = ""

proc skip*(lexer: var CSVLexer) =
    lexer.bufpos.inc

proc get_char*(lexer: CSVLexer): char =
    lexer.buf[lexer.bufpos]

proc consume*(lexer: var CSVLexer): char =
    result = lexer.get_char
    lexer.skip

proc set_error*(lexer: var CSVLexer, error_message: string) =
    lexer.kind = tk_invalid
    if lexer.error.len == 0:
        # lexer.error = &"{lexer.file_path}({lexer.getColNumber( lexer.bufpos )+1},{lexer.lineNumber}) {error_message} \n {lexer.get_char} {lexer.getCurrentLine}"
        lexer.error = &"{lexer.file_path}({lexer.lineNumber},{lexer.bufpos}) {error_message} \n {lexer.get_char} {lexer.getCurrentLine}"

proc has_error*(lexer: CSVLexer): bool =
    lexer.error.len > 0


proc handle_new_line*(lexer: var CSVLexer) =
    lexer.kind = tk_new_line
    case lexer.get_char
    of '\c':
        lexer.bufpos = lexer.handleCR lexer.bufpos
    of '\n':
        lexer.bufpos = lexer.handleLF lexer.bufpos
    else:
        lexer.set_error("Not a valid newline symbol")


proc handle_value(lexer: var CSVLexer) =
    var isEscaped = false
    lexer.kind = tk_int
    if lexer.get_char == '"':
        lexer.kind = tk_string
        isEscaped = true
        lexer.skip
    while true:
        case lexer.get_char:
        of lexbase.Newlines:
            lexer.handle_new_line
            if lexer.get_char == EndOfFile:
                break
            if isEscaped:
                lexer.token.add lexer.consume
            else:
                break
        of EndOfFile:
            break
        of ',':
            if isEscaped:
                lexer.token.add lexer.consume
            else:
                lexer.kind = tk_string
                lexer.skip
                break
        of '0'..'9':
            lexer.token.add lexer.consume
        of '.':
            if lexer.kind == tk_int:
                lexer.kind = tk_float
            elif lexer.kind == tk_float:
                lexer.kind = tk_string
            lexer.token.add lexer.consume
        of '"':
            # check if there are two double quotes
            lexer.skip
            if lexer.get_char == '"':
                lexer.token.add lexer.consume
            elif lexer.get_char == ',':
                lexer.kind = tk_string
                lexer.skip
                break
            else:
                lexer.token.add lexer.consume
        else:
            lexer.kind = tk_string
            lexer.token.add lexer.consume

proc get_token(lexer: var CSVLexer): CSV_Token =
    lexer.token = ""
    lexer.kind = tk_invalid
    case lexer.get_char:
    of lexbase.NewLines: 
        lexer.handle_new_line
        lexer.kind = tk_new_line
        lexer.skip
    of EndOfFile:
        lexer.kind = tk_end_of_input
    else: lexer.handle_value
    return lexer.kind


proc processStream*(lexer: var CSVLexer): seq[seq[Base_Type]] =
    var tempRow: seq[Base_Type] = @[]
    while lexer.get_token notin { tk_invalid }:
        case lexer.kind:
        of tk_end_of_input:
            result.add tempRow
            tempRow = @[]
            break
        of tk_new_line:
            result.add tempRow
            tempRow = @[]
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


proc processStreamAsString*(lexer: var CSVLexer): seq[seq[string]] =
    var tempRow: seq[string] = @[]
    while lexer.get_token notin { tk_invalid }:
        case lexer.kind:
        of tk_end_of_input:
            result.add tempRow
            tempRow = @[]
            break
        of tk_new_line:
            result.add tempRow
            tempRow = @[]
        of tk_int:
            tempRow.add lexer.token
        of tk_float:
            tempRow.add lexer.token
        of tk_string:
            tempRow.add lexer.token
        else:
            lexer.kind = tk_invalid
    if lexer.has_error:
        echo lexer.error

when isMainModule:
    proc main() =
        var lexer: CSVLexer
        if paramCount() < 1:
            echo "Waiting STDIN..."
            lexer.open newFileStream stdin
        else:
            lexer.file_path = absolute_path(paramStr 1)
            echo "reading file ", lexer.file_path
            let temp_file_stream = newFileStream lexer.file_path
            lexer.open temp_file_stream
    main()
