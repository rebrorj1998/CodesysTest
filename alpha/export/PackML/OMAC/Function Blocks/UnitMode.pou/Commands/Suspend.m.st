(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Suspend : BOOL
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
CASE eState OF
PackMLState.Execute:
	IF (PackMLState.Suspending AND SupportedStates) = 0 THEN
		Suspend := FALSE;
		RETURN;
	END_IF
	eState := PackMLState.Suspending;
	Suspend := TRUE;
END_CASE
	