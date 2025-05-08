(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Reset : BOOL
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
CASE eState OF
PackMLState.Complete,
PackMLState.Stopped:
	IF (PackMLState.Resetting AND SupportedStates) = 0 THEN
		Reset := FALSE;
		RETURN;
	END_IF
	eState := PackMLState.Resetting;
	Reset := TRUE;
END_CASE
	