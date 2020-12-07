(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Implicitly generated code : DO NOT EDIT
FUNCTION CheckDivLInt : LINT
VAR_INPUT
	divisor:LINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Implicitly generated code: Only an implementation suggestion
IF divisor = 0 THEN
	CheckDivLInt:=1;
ELSE
	CheckDivLInt:=divisor;
END_IF;