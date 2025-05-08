(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Get the next machine state without checking the supported states.
METHOD NextState : PackMLState
VAR_INPUT
	e: PackMLState;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
CASE e OF
PackMLState.Stopped:
	NextState := PackMLState.Resetting;
PackMLState.Resetting:
	NextState := PackMLState.Idle;
PackMLState.Idle:
	NextState := PackMLState.Starting;
PackMLState.Starting:
	NextState := PackMLState.Execute;
PackMLState.Execute:
	NextState := PackMLState.Invalid;
PackMLState.Holding:
	NextState := PackMLState.Held;
PackMLState.Held:
	NextState := PackMLState.UnHolding;
PackMLState.UnHolding:
	NextState := PackMLState.Execute;
PackMLState.Suspending:
	NextState := PackMLState.Suspended;
PackMLState.Suspended:
	NextState := PackMLState.UnSuspending;
PackMLState.UnSuspending:
	NextState := PackMLState.Execute;
PackMLState.Completing:
	NextState := PackMLState.Complete;
PackMLState.Complete:
	NextState := PackMLState.Resetting;
PackMLState.Stopping:
	NextState := PackMLState.Stopped;
PackMLState.Aborting:
	NextState := PackMLState.Aborted;
PackMLState.Aborted:
	NextState := PackMLState.Clearing;
PackMLState.Clearing:
	NextState := PackMLState.Stopped;
END_CASE