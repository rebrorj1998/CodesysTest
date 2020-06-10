(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Resetting
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
currentBaggerState := 'Resetting';
state := HEAD_STATES.Idle;
sealAndSeparateSubState := SEAL_SEPARATE_STATES.Idle;
releaseAndFeedSubState := RELEASE_FEED_STATES.Idle;
bagOpenSubState := BAG_OPEN_ASSIST_STATES.Idle;

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
		
		bagger.bagDelivery.Reset();
		HomeIfNeeded(bagger.pressureBar);
		HomeIfNeeded(bagger.sealFlatteners);
		HomeIfNeeded(bagger.loadPlate);
		HomeIfNeeded(bagger.IBD);
		resettingState := 1;
		
		
		
	1:	// Move everything into place to start machine
		IF CheckIfHomed(bagger.pressureBar) THEN
			PostHomeMoveIfNeeded(bagger.pressureBar);
			resettingState := 2;
		END_IF
	
	2:	// Once everything is moved into position and ready move on
		IF (bagger.pressureBar.Ready OR NOT bagger.pressureBar.OptionActive) 
			AND (bagger.IBD.Ready OR NOT bagger.IBD.OptionActive)
			AND (bagger.printer.Ready OR NOT bagger.printer.OptionActive)
			AND (bagger.bagDelivery.Ready)
		THEN
			_resettingDone := TRUE;
			resettingState := 0;
		END_IF
	
END_CASE

