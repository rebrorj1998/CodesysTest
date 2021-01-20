(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Unpack
VAR_IN_OUT
    modbusLong : ModbusLongType;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
modbusLong.highWord := OSCAT_BASIC.WORD_OF_DWORD(in := DINT_TO_DWORD(modbusLong.rawValue), N := 1);
modbusLong.lowWord := OSCAT_BASIC.WORD_OF_DWORD(in := DINT_TO_DWORD(modbusLong.rawValue), N := 0);