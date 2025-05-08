(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Clear : BOOL
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
CASE eState OF
PackMLState.Aborted:
	IF (PackMLState.Clearing AND SupportedStates) = 0 THEN
		Clear := FALSE;
		RETURN;
	END_IF
	eState := PackMLState.Clearing;
	Clear := TRUE;
END_CASE
	