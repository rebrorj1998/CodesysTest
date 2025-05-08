(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD UnSuspend : BOOL
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
CASE eState OF
PackMLState.Suspended:
	IF (PackMLState.UnSuspending AND SupportedStates) = 0 THEN
		UnSuspend := FALSE;
		RETURN;
	END_IF
	eState := PackMLState.UnSuspending;
	UnSuspend := TRUE;
END_CASE
	