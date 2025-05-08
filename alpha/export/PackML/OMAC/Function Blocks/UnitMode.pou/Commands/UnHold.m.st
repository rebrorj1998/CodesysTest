(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD UnHold : BOOL
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
CASE eState OF
PackMLState.Held:
	IF (PackMLState.UnHolding AND SupportedStates) = 0 THEN
		UnHold := FALSE;
		RETURN;
	END_IF
	eState := PackMLState.UnHolding;
	UnHold := TRUE;
END_CASE
	