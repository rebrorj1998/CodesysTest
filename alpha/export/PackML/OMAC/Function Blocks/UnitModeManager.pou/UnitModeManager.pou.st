(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Function block to switch the current unit mode.
{attribute 'hide_all_locals'} 
FUNCTION_BLOCK UnitModeManager
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
	apum: ARRAY[1..gc_usiMaxModes] OF IUnitMode;
	usiNumberOfUMs : USINT := 0;
	usiActualUM: USINT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
