(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Abort : BOOL
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
CASE eState OF
PackMLState.Stopped,
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
PackMLState.Complete,
PackMLState.Stopping,
PackMLState.Clearing:
	IF (PackMLState.Aborting AND SupportedStates) = 0 THEN
		Abort := FALSE;
		RETURN;
	END_IF
	eState := PackMLState.Aborting;
	Abort := TRUE;
END_CASE
	