(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK HeadRaiseLowerFB
VAR_INPUT
	upperLimitProx : BOOL;
	lowerLimitProx : BOOL;
	raiseCommand : BOOL;
	lowerCommand : BOOL;
END_VAR
VAR_OUTPUT
	raiseOutput : BOOL;
	lowerOutput : BOOL;
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF raiseCommand AND NOT upperLimitProx THEN
	raiseOutput := TRUE;
ELSE
	raiseOutput := FALSE;
END_IF

IF lowerCommand AND NOT lowerLimitProx THEN
	lowerOutput := TRUE;
ELSE
	lowerOutput := FALSE;
END_IF