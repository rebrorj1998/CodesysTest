(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_AuxIO_RemoteComms
VAR_INPUT
	bagsLow : BOOL;
	faultActive : BOOL;
	inhibitCycle : BOOL;
	printerDataReady : BOOL;
	waitingForFiller : BOOL;
	runExitConveyor : BOOL;
	state : StateMachine;
	activeFaults   : ARRAY[0..GlobalObjects.MAX_FAULTS] OF STRING;

END_VAR
VAR_OUTPUT
	baggerOK : BOOL;
	fillerOK : BOOL;
	bagGrabbed : BOOL;
	enableBagger : BOOL;
	inhibitBagger : BOOL;
	reverseConveyor : BOOL;
END_VAR
VAR
	_configOutputManager : FB_OutputPulseManager;
	_readyForGrab : BOOL;
	_readyForGrabONS : Standard.R_TRIG();
	_outputPulse_CycleComplete : FB_MonostableMultivibrator();
	_OutputPulse_BagMade : FB_MonostableMultivibrator();
	_heartbeatWarningTimer : TON := (PT := T#1000MS);
END_VAR

(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

_OutputPulse_CycleComplete(Q => RemoteComms.cycleComplete);
_outputPulse_CycleComplete.DwellSetting := 500;
_OutputPulse_BagMade(Q => RemoteComms.BagMade);
_OutputPulse_BagMade.DwellSetting := 500;


IF HMIData.remoteComsEnable THEN
	//		
		(* Inputs *)	
	
		// Baggers not faults and heated up.
		baggerOK := NOT faultActive;		
		 
        // Filler is ready
        fillerOK := RemoteComms.fillerOK;
        
        // Active if either input is set to 'BaggerInhibit' and the corresponding input is active, or PAA enabled and inhibiting cycle.
        inhibitBagger := RemoteComms.inhibitCycle OR inhibitCycle;		
		
		// Custom PRJ-22085: Robot successfully grabbed bag.
		bagGrabbed := RemoteComms.bagGrabbed;
		
		// Custom PRJ-59126: Reverse BEC when high
		reverseConveyor := RemoteComms.reverseConveyor;
		
		// Custom PRJ-MFT01: Enable Bagger
	 	enableBagger := RemoteComms.enableBagger;
		
		
		(* Outputs *)		
				// Cycle Complete
		IF state.head = HEAD_STATES.OpenedBag THEN
			_OutputPulse_CycleComplete.Trigger();
		END_IF
		
		// Bag Made
		IF state.head = HEAD_STATES.SealedAndSeparatedBag THEN
			_OutputPulse_BagMade.Trigger();
		END_IF		
		

				
		RemoteComms.readyForFiller := waitingForFiller;
		RemoteComms.bagsLow := bagsLow;
		RemoteComms.printerDataReady := printerDataReady;
		RemoteComms.waitingForPrinter := state.sb.releaseFeed = RELEASE_FEED_STATES.WaitForPrinter;
		RemoteComms.runExitConveyor := runExitConveyor;
		// Bag Made Plus Label Required
		IF NOT printerDataReady AND state.head = HEAD_STATES.SealedAndSeparatedBag THEN
			RemoteComms.bagMadePlusLabelRequired := TRUE;
		END_IF
				
		IF printerDataReady OR faultActive OR (state.sb.releaseFeed = RELEASE_FEED_STATES.FeedToOffset) THEN
			RemoteComms.bagMadePlusLabelRequired := FALSE;
		END_IF	

//Heartbeat

	_heartbeatWarningTimer();
	IF RemoteComms.heartbeat THEN	
		RemoteComms.heartbeat := FALSE;
		_heartbeatWarningTimer.IN := FALSE;
		hmidata.remoteComsHeartbeat.active := FALSE;		
	ELSE
		_heartbeatWarningTimer.IN :=TRUE;
		hmidata.remoteComsHeartbeat.active := _heartbeatWarningTimer.Q;		
	END_IF
	
//Fault Passing
	RemoteComms.activeFaults := activeFaults;
			
ELSE
		// Turn outputs off
		RemoteComms.bagsLow := FALSE;
		RemoteComms.inhibitCycle := FALSE;
		RemoteComms.printerDataReady := FALSE;		
		RemoteComms.runExitConveyor := FALSE;	
		RemoteComms.heartbeat := FALSE;	
		
		RemoteComms.baggerOK := FALSE;
		RemoteComms.bagGrabbed := FALSE;
		RemoteComms.bagMade := FALSE;
		RemoteComms.bagMadePlusLabelRequired := FALSE;
		RemoteComms.cycleComplete := FALSE;
		RemoteComms.enableBagger := FALSE;
		RemoteComms.fillerOK := FALSE;
		RemoteComms.inhibitBagger := FALSE;
		RemoteComms.readyForFiller := FALSE;
		RemoteComms.reverseConveyor := FALSE;
		RemoteComms.waitingForPrinter := FALSE;

END_IF 