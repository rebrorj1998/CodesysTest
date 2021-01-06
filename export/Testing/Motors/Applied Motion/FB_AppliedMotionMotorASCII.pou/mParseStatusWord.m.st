(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE mParseStatusWord : DWORD
VAR_INPUT
	stringInput : STRING;
END_VAR
VAR 
	substring : STRING;
	buffer : ARRAY[0..3] OF BYTE;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
substring := Standard.RIGHT(stringInput, 5);
substring := Standard.LEFT(substring,4);
mParseStatusWord := OSCAT_BASIC.HEX_TO_DWORD(substring);