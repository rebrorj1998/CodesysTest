(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Implicitly generated code : DO NOT EDIT
FUNCTION CheckDivLReal : LREAL
VAR_INPUT
	divisor:LREAL;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Implicitly generated code: Only an implementation suggestion
IF divisor = 0 THEN
	CheckDivLReal:=1;
ELSE
	CheckDivLReal:=divisor;
END_IF;