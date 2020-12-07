(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_BaggerHeadRaise
VAR_INPUT
	faultIndication : BOOL;
	raiseCommand : BOOL;
	lowerCommand : BOOL;
	raiseLimitSwitch : BOOL;
	lowerLimitSwitch : BOOL;
END_VAR
VAR_OUTPUT
	runMotorOutput : BOOL;
	motorDirectionOutput : BOOL;
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF NOT faultIndication THEN
	IF (raiseCommand AND NOT raiseLimitSwitch) OR (lowerCommand AND NOT lowerLimitSwitch) THEN
		runMotorOutput := TRUE;
	ELSE
		runMotorOutput := FALSE;
	END_IF
	
	IF (lowerCommand AND NOT lowerLimitSwitch) THEN
		motorDirectionOutput := TRUE;
	ELSE
		motorDirectionOutput := FALSE;
	END_IF
	
ELSE
	runMotorOutput := FALSE;
	motorDirectionOutput := FALSE;
END_IF


