(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CycleFirstBagOut EXTENDS FB_BaseComponent
VAR_INPUT
	firstBagFromCageActive : BOOL;
	inclinePackageAtExit : BOOL;
END_VAR
VAR_OUTPUT
	state : CycleFirstBagOutOfCageStates;
	active : BOOL;
	pauseConveyor : BOOL;
END_VAR
VAR
	_removedBagDebounceTimer : TON := (PT := T#150MS);
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: FB_CycleFirstBagOut
//    Description: Handle a package that is the first bag out from the cage - needs to stop at the incline.
//    Created by: Ben Hess
//    Created Date: September 28th, 2023


SUPER^();
IF resetONS.Q THEN
	state := CycleFirstBagOutOfCageStates.Idle;
END_IF

// Debounce timer for when associate removes package from incline
_removedBagDebounceTimer(IN := NOT inclinePackageAtExit);

IF NOT firstBagFromCageActive THEN
	state := CycleFirstBagOutOfCageStates.Idle;
END_IF

CASE state OF

	CycleFirstBagOutOfCageStates.Idle:
		IF firstBagFromCageActive THEN
			state := CycleFirstBagOutOfCageStates.WaitForBagToReachEndOfIncline;
		END_IF	

	CycleFirstBagOutOfCageStates.WaitForBagToReachEndOfIncline:
		IF inclinePackageAtExit THEN
			state := CycleFirstBagOutOfCageStates.PauseForOperatorRemoval;
		END_IF
	
	CycleFirstBagOutOfCageStates.PauseForOperatorRemoval:
		IF _removedBagDebounceTimer.Q THEN
			state := CycleFirstBagOutOfCageStates.Idle;
		END_IF
	
END_CASE

// Set ouputs

active := state <> CycleFirstBagOutOfCageStates.Idle;
pauseConveyor := state = CycleFirstBagOutOfCageStates.PauseForOperatorRemoval;