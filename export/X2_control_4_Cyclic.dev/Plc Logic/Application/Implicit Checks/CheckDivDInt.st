(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Implicitly generated code : DO NOT EDIT
FUNCTION CheckDivDInt : DINT
VAR_INPUT
	divisor:DINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Implicitly generated code: Only an implementation suggestion
IF divisor = 0 THEN
	CheckDivDInt:=1;
ELSE
	CheckDivDInt:=divisor;
END_IF;