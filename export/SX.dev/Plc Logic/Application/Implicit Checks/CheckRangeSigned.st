(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Implicitly generated code : DO NOT EDIT
FUNCTION CheckRangeSigned : DINT
VAR_INPUT
	value, lower, upper: DINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Implicitly generated code: Only an implementation suggestion
IF (value < lower) THEN
	CheckRangeSigned := lower;
ELSIF(value > upper) THEN
	CheckRangeSigned := upper;
ELSE
	CheckRangeSigned := value;
END_IF