(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Pack
VAR_IN_OUT
    modbusLong : ModbusLongType;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
modbusLong.rawValue := DWORD_TO_DINT(OSCAT_BASIC.DWORD_OF_WORD(modbusLong.highWord,modbusLong.lowWord));