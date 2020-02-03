(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CylinderFaults
VAR_INPUT
	enable : BOOL;
	extendCommand : BOOL;
	extendedInput : BOOL;
	retractCommand : BOOL;
	retractedInput : BOOL;
	faultTime : TIME := T#2500ms;
END_VAR
VAR_OUTPUT
	failToExtend : BOOL;
	failToRetract : BOOL;
END_VAR
VAR
	extendFaultTimer : Standard.TON;
	retractFaultTimer : Standard.TON;
END_VAR
VAR_IN_OUT
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
extendFaultTimer(PT := faultTime, Q => failToExtend);
retractFaultTimer(PT := faultTime, Q => failToRetract);
IF enable THEN
	IF extendCommand THEN
		retractFaultTimer.IN := FALSE;
		extendFaultTimer.IN := NOT extendedInput;
	ELSIF retractCommand THEN
		extendFaultTimer.IN := FALSE;
		retractFaultTimer.IN := NOT retractedInput;
	ELSE
		retractFaultTimer.IN := FALSE;
		extendFaultTimer.IN := FALSE;
	END_IF
ELSE
	retractFaultTimer.IN := FALSE;
	extendFaultTimer.IN := FALSE;
END_IF