import lexbase
import streams
import strformat

when isMainModule:
    import os

type
    CSV_Token* = enum
        tk_invalid
        tk_value
        tk_end_of_input

    Lexer* = object of BaseLexer
        kind*: CSV_Token
        token*: string
        error*: string
        start_pos*: int
        file_path*: string


proc open*(lexer: var Lexer, input: Stream) =
    lexbase.open(lexer, input)
    lexer.start_pos = 0
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

proc get_token(lexer: var Lexer): CSV_Token =
    lexer.token.setLen 0
    case lexer.get_char
    of '0'..'9': 
        # number
        lexer.kind = tk_value
        lexer.token.add lexer.consume
        while expression:
            
    else: lexer.handle_string
    result = lexer.kind
    

when isMainModule:
    proc main() =
        var lexer: Lexer
        if paramCount() < 1:
            echo "Waiting STDIN..."
            lexer.open newFileStream stdin
        else:
            try:
                lexer.file_path = absolute_path(paramStr 1)
                echo "reading file ", lexer.file_path
                let temp_file_stream = newFileStream lexer.file_path
                lexer.open temp_file_stream
            except AssertionError:
                lexer.file_path = ""
                echo "lexing string", paramStr 1
                let temp_str_stream = newStringStream(paramStr 1)
                lexer.open temp_str_stream
        while lexer.get_token notin { tk_invalid }:
            if lexer.kind == tk_end_of_input:
                break
            else:
                stdout.write &"{lexer.lineNumber:5}  {lexer.startPos + 1:5}  {lexer.kind:<14}"
                stdout.write &" {lexer.token} \n"
        if lexer.has_error:
            echo lexer.error
    main()
