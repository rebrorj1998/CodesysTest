

FUNCTION_BLOCK ModbusLongHandlerFB
VAR_INPUT
    modbusLong : ModbusLongType;
END_VAR
VAR_OUTPUT
END_VAR
VAR
END_VAR


METHOD PackDirect : ModbusLongType
VAR_INPUT
    highWord : WORD;
    lowWord : WORD
;END_VAR

PackDirect.rawValue :=  DWORD_TO_DINT(OSCAT_BASIC.DWORD_OF_WORD(highWord,lowWord));

METHOD Pack
VAR_IN_OUT
    modbusLong : ModbusLongType;
END_VAR

modbusLong.rawValue := DWORD_TO_DINT(OSCAT_BASIC.DWORD_OF_WORD(modbusLong.highWord,modbusLong.lowWord));

METHOD Unpack
VAR_IN_OUT
    modbusLong : ModbusLongType;
END_VAR

modbusLong.highWord := OSCAT_BASIC.WORD_OF_DWORD(in := DINT_TO_DWORD(modbusLong.rawValue), N := 1);
modbusLong.lowWord := OSCAT_BASIC.WORD_OF_DWORD(in := DINT_TO_DWORD(modbusLong.rawValue), N := 0);