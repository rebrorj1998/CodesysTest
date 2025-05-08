(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Stop : BOOL
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
CASE eState OF
PackMLState.Resetting,
PackMLState.Idle,
PackMLState.Starting,
PackMLState.Execute,
PackMLState.Holding,
PackMLState.Held,
PackMLState.UnHolding,
PackMLState.Suspending,
PackMLState.Suspended,
PackMLState.UnSuspending,
PackMLState.Completing,
PackMLState.Complete:
	IF (PackMLState.Stopping AND SupportedStates) = 0 THEN
		Stop := FALSE;
		RETURN;
	END_IF
	eState := PackMLState.Stopping;
	Stop := TRUE;
END_CASE
	