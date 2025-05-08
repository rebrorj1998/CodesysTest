(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// This method should be called by the program if an action has been finished.
METHOD ActingStateCompleted : BOOL
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
CASE eState OF
PackMLState.Holding,
PackMLState.UnHolding,
PackMLState.Starting,
PackMLState.Completing,
PackMLState.Resetting,
PackMLState.UnSuspending,
PackMLState.Suspending,
PackMLState.Aborting,
PackMLState.Stopping,
PackMLState.Clearing:
	IF (NextState(eState) AND SupportedStates) = 0 THEN
		ActingStateCompleted := FALSE;
		RETURN;
	END_IF
	eState := NextState(eState);
	ActingStateCompleted := TRUE;
	
PackMLState.Execute:
	IF (PackMLState.Completing AND SupportedStates) = 0 THEN
		ActingStateCompleted := FALSE;
		RETURN;
	END_IF
	eState := PackMLState.Completing;
	ActingStateCompleted := TRUE;
END_CASE

IF eState = PackMLState.Invalid THEN
	ActingStateCompleted := FALSE;
END_IF