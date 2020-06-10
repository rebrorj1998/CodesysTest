(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Clearing
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF NOT resetTriggered THEN
	bagger.pressureBar.Reset();
	bagger.IBD.Reset();
	bagger.loadPlate.Reset();
	_completingDone := FALSE;
	_holdingDone := FALSE;
	_resettingDone := FALSE;
	_startingDone := FALSE;
	_unholdingDone := FALSE;
	_stoppingDone := FALSE;
	resetTriggered := TRUE;
	_clearingDone := TRUE;
END_IF

// IF bagger.pressureBar.Ready THEN
// 	_clearingDone := TRUE;
// 	resetTriggered := FALSE;
// END_IF