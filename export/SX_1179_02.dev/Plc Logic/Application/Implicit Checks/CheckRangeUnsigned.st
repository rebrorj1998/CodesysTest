(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Implicitly generated code : DO NOT EDIT
FUNCTION CheckRangeUnsigned : UDINT
VAR_INPUT
	value, lower, upper: UDINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Implicitly generated code: Only an implementation suggestion
IF (value < lower) THEN
	CheckRangeUnsigned := lower;
ELSIF(value > upper) THEN
	CheckRangeUnsigned := upper;
ELSE
	CheckRangeUnsigned := value;
END_IF