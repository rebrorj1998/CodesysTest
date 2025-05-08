(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Hold : BOOL
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
CASE eState OF
PackMLState.Execute:
	IF (PackMLState.Holding AND SupportedStates) = 0 THEN
		Hold := FALSE;
		RETURN;
	END_IF
	eState := PackMLState.Holding;
	Hold := TRUE;
END_CASE
	