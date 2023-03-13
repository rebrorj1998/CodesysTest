(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Implicitly generated code : DO NOT EDIT
FUNCTION CheckLRangeUnsigned : ULINT
VAR_INPUT
	value, lower, upper: ULINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Implicitly generated code: Only an implementation suggestion
IF (value < lower) THEN
	CheckLRangeUnsigned := lower;
ELSIF(value > upper) THEN
	CheckLRangeUnsigned := upper;
ELSE
	CheckLRangeUnsigned := value;
END_IF