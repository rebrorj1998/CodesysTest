(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CylinderFaults
VAR_INPUT
	feedback : eActuatorFeedbackType;
	extendCommand : BOOL;
	extendedInput : BOOL;
	retractCommand : BOOL;
	retractedInput : BOOL;
	faultTime : TIME := T#2500ms;
END_VAR
VAR_OUTPUT
	_reset : BOOL;
	failToExtend : BOOL;
	failToRetract : BOOL;
END_VAR
VAR
	extendFaultTimer : Standard.TON;
	retractFaultTimer : Standard.TON;
END_VAR
VAR_IN_OUT
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

// Clear Faults
IF _reset THEN
	_reset := TRUE;
	retractFaultTimer.IN := FALSE;
	extendFaultTimer.IN := FALSE;	
END_IF

// 
extendFaultTimer(PT := faultTime, Q => failToExtend);
retractFaultTimer(PT := faultTime, Q => failToRetract);
IF extendCommand THEN
	IF feedback = eActuatorFeedbackType.Both OR feedback = eActuatorFeedbackType.Extended THEN
		retractFaultTimer.IN := FALSE;
		extendFaultTimer.IN := NOT extendedInput;
	END_IF
ELSIF retractCommand THEN
	IF feedback = eActuatorFeedbackType.Both OR feedback = eActuatorFeedbackType.Retracted THEN
		extendFaultTimer.IN := FALSE;
		retractFaultTimer.IN := NOT retractedInput;
	END_IF
ELSE
	retractFaultTimer.IN := FALSE;
	extendFaultTimer.IN := FALSE;
END_IF
