(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Aborting
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
currentBaggerState := 'Aborting';
IF NOT _abortingDone THEN
	_clearingDone := FALSE;
	_completingDone := FALSE;
	_holdingDone := FALSE;
	_resettingDone := FALSE;
	_startingDone := FALSE;
	_unholdingDone := FALSE;
	_stoppingDone := FALSE;
	resetTriggered := FALSE;
	resetFailed := FALSE;
	resettingTimer.IN := FALSE;
	baggerCycleActive := FALSE;
	resettingState := 0;
	bagger.bagOpenFingers.RemovePower();
	bagger.vacuumBagOpen.StopVacuum();
	bagger.pressureBar.RemovePower();
	bagger.IBD.RemovePower();
	bagger.barcodeVerifier.Reset();
	bagger.StartCycleRequest := FALSE;
	bagger.ReadyForProduct := FALSE;
	bagger.CurrentBagOpenRetryCount := 0;
	bagger.StartCycleRequest := FALSE;
	state := HEAD_STATES.Idle;
	sealAndSeparateSubState := SEAL_SEPARATE_STATES.Idle;
    releaseAndFeedSubState := RELEASE_FEED_STATES.Idle;
    bagOpenSubState := BAG_OPEN_ASSIST_STATES.Idle;
	cycleTimer.IN := FALSE;
	cycleComplete := FALSE;
	_abortingDone := TRUE;
END_IF
