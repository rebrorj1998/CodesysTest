(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_AuxIO_RemoteComs
VAR_INPUT
	bagsLow : BOOL;
	faultActive : BOOL;
	inhibitCycle : BOOL;
	printerDataReady : BOOL;
	waitingForFiller : BOOL;
	runExitConveyor : BOOL;
	state : StateMachine;

END_VAR
VAR_OUTPUT
	baggerOK : BOOL;
	fillerOK : BOOL;
	bagGrabbed : BOOL;
	enableBagger : BOOL;
	inhibitBagger : BOOL;
	reverseConveyor : BOOL;
	readyForFiller : BOOL;
END_VAR
VAR
	_configOutputManager : FB_OutputPulseManager;
	_readyForGrab : BOOL;
	_readyForGrabONS : Standard.R_TRIG();
	_outputPulse_CycleComplete : FB_MonostableMultivibrator();
	_OutputPulse_BagMade : FB_MonostableMultivibrator();
	_heartbeatFaultTimer : TON := (PT := T#1000MS);
END_VAR

(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

_OutputPulse_CycleComplete(Q => RemoteComs.cycleComplete);
_outputPulse_CycleComplete.DwellSetting := 500;
_OutputPulse_BagMade(Q => RemoteComs.BagMade);
_OutputPulse_BagMade.DwellSetting := 500;


IF HMIData.remoteComsEnable THEN
	//		
		(* Inputs *)	
	
		// Baggers not faults and heated up.
		baggerOK := NOT faultActive;		
		 
        // Filler is ready
        fillerOK := RemoteComs.fillerOK;
        
        // Active if either input is set to 'BaggerInhibit' and the corresponding input is active, or PAA enabled and inhibiting cycle.
        inhibitBagger := RemoteComs.inhibitCycle OR inhibitCycle;		
		
		// Custom PRJ-22085: Robot successfully grabbed bag.
		bagGrabbed := RemoteComs.bagGrabbed;
		
		// Custom PRJ-59126: Reverse BEC when high
		reverseConveyor := RemoteComs.reverseConveyor;
		
		// Custom PRJ-MFT01: Enable Bagger
	 	enableBagger := RemoteComs.enableBagger;
		
		(* Outputs *)
		
				// Cycle Complete
		IF state.head = HEAD_STATES.OpenedBag THEN
			_OutputPulse_CycleComplete.Trigger();
		END_IF
		
		// Bag Made
		IF state.head = HEAD_STATES.SealedAndSeparatedBag THEN
			_OutputPulse_BagMade.Trigger();
		END_IF		
		

				
		remotecoms.readyForFiller := waitingForFiller;
		RemoteComs.bagsLow := bagsLow;
		RemoteComs.printerDataReady := printerDataReady;
		RemoteComs.waitingForPrinter := state.sb.releaseFeed = RELEASE_FEED_STATES.WaitForPrinter;
		RemoteComs.runExitConveyor := runExitConveyor;
		// Bag Made Plus Label Required
		IF NOT printerDataReady AND state.head = HEAD_STATES.SealedAndSeparatedBag THEN
			RemoteComs.bagMadePluseLabelRequired := TRUE;
		END_IF
				
		IF printerDataReady OR faultActive OR (state.sb.releaseFeed = RELEASE_FEED_STATES.FeedToOffset) THEN
			RemoteComs.bagMadePluseLabelRequired := FALSE;
		END_IF	

//Heartbeat
	IF RemoteComs.heartbeat THEN	
		RemoteComs.heartbeat := FALSE;
	ELSE
		_heartbeatFaultTimer.IN :=TRUE;
		
	END_IF

			
ELSE
		// Turn outputs off
		RemoteComs.bagsLow := FALSE;
		RemoteComs.inhibitCycle := FALSE;
		RemoteComs.printerDataReady := FALSE;		
		RemoteComs.runExitConveyor := FALSE;	
		RemoteComs.heartbeat := FALSE;	
		
		RemoteComs.baggerOK := FALSE;
		RemoteComs.bagGrabbed := FALSE;
		Remotecoms.bagMade := FALSE;
		RemoteComs.bagMadePluseLabelRequired := FALSE;
		RemoteComs.cycleComplete := FALSE;
		RemoteComs.enableBagger := FALSE;
		RemoteComs.fillerOK := FALSE;
		RemoteComs.inhibitBagger := FALSE;
		RemoteComs.readyForFiller := FALSE;
		RemoteComs.reverseConveyor := FALSE;
		RemoteComs.waitingForPrinter := FALSE;

END_IF 