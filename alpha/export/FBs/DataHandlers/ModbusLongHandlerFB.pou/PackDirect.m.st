(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PackDirect : ModbusLongType
VAR_INPUT
    highWord : WORD;
    lowWord : WORD
;END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PackDirect.rawValue :=  DWORD_TO_DINT(OSCAT_BASIC.DWORD_OF_WORD(highWord,lowWord));