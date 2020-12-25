type
    Base_Type_Kinds* = enum
        btk_int
        btk_float
        btk_string
        btk_nil

    Base_Type* = object
        case kind*: Base_Type_Kinds
        of btk_int:
            int_val*: int
        of btk_string:
            string_val*: string
        of btk_float:
            float_val*: float
        of btk_nil:
            nil