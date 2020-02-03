(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
_rawValue := RawValue;
_highWord := OSCAT_BASIC.WORD_OF_DWORD(in := _rawValue, N := 1);
_lowWord := OSCAT_BASIC.WORD_OF_DWORD(in := _rawValue, N := 0);