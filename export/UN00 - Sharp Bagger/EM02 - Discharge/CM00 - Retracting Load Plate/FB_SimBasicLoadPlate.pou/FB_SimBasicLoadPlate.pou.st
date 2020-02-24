(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_SimBasicLoadPlate EXTENDS FB_BaseComponent IMPLEMENTS IRetractingLoadPlate, IExecuteAutomatically
VAR_INPUT
	loadPlateDwell : REAL := 2.5;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	beginDischarge : FB_SimulatedFeedback(name := CONCAT(_prefix,'Begin Discharge'));
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
