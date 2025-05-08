(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Start : BOOL
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
CASE eState OF
PackMLState.Idle:
	IF (PackMLState.Starting AND SupportedStates) = 0 THEN
		Start := FALSE;
		RETURN;
	END_IF
	eState := PackMLState.Starting;
	Start := TRUE;
END_CASE
	