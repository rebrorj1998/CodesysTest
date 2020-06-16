(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Resetting
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
currentBaggerState := 'Resetting';
state := HEAD_STATES.Idle;
sealAndSeparateSubState := SEAL_SEPARATE_STATES.Idle;
releaseAndFeedSubState := RELEASE_FEED_STATES.Idle;
bagOpenSubState := BAG_OPEN_ASSIST_STATES.Idle;
resettingTimer();

CASE resettingState OF
	0:	// Clear PackML state bits and Home everything that needs homing
		_clearingDone := FALSE;
		_completingDone := FALSE;
		_holdingDone := FALSE;
		_resettingDone := FALSE;
		_startingDone := FALSE;
		_unholdingDone := FALSE;
		_stoppingDone := FALSE;
		
		vacuumDwellTimer.IN := FALSE;
		
		GlobalObjects.CollectionOfComponents.ResetAll();
		resettingTimer.IN := TRUE;
		resettingTimer.PT := T#500MS;
		resettingState := 1;
	
	1: // Wait for reset.  If not reset all try again once, then back to abort
// 		IF resettingTimer.Q AND NOT resetFailed THEN
// 			IF resetFailed THEN
// 				resettingState := 0;
// 			ELSE
// 				resetFailed := TRUE;
// 			END_IF
// 			resettingTimer.IN := FALSE;
// 		END_IF
		IF NOT alarmActive AND resettingTimer.Q THEN
			resettingTimer.IN := FALSE;
			resettingState := 2;
		END_IF
		
	
	2:	// Home everything
		GlobalObjects.CollectionOfComponents.HomeAll();
		resettingState := 3;
		
	3:	// Move everything into place to start machine
		resettingTimer.PT := T#10S;
		resettingTimer.IN := TRUE;
		IF resettingTimer.Q THEN
			resetFailed := TRUE;
			resettingTimer.IN := FALSE;
			resettingState := 4;
		END_IF
		
		IF GlobalObjects.CollectionOfComponents.CheckIfAllReady() 
		THEN
			_resettingDone := TRUE;
			resettingTimer.IN := FALSE;
			resettingState := 4;
		END_IF
	
	4:	// Once everything is moved into position and ready move on
		resettingState := 0;
	
	
END_CASE

