(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Implicitly generated code : DO NOT EDIT
FUNCTION CheckLRangeSigned : LINT
VAR_INPUT
	value, lower, upper: LINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Implicitly generated code: Only an implementation suggestion
IF (value < lower) THEN
	CheckLRangeSigned := lower;
ELSIF(value > upper) THEN
	CheckLRangeSigned := upper;
ELSE
	CheckLRangeSigned := value;
END_IF