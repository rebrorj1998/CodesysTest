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
	_heartbeatWarningTimerOn : TON := (PT := T#1000MS);
	_heartbeatWarningTimerOff : TON := (PT := T#1000MS);
END_VAR

(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

_OutputPulse_CycleComplete(Q => RemoteComms.outputsFromBagger.cycleComplete);
_outputPulse_CycleComplete.DwellSetting := 500;
_OutputPulse_BagMade(Q => RemoteComms.outputsFromBagger.bagMade);
_OutputPulse_BagMade.DwellSetting := 500;

IF NOT HMIData.auxIOSource.OPC_UA THEN
    // Turn outputs off
    RemoteComms.outputsFromBagger.bagsLow := FALSE;
    //RemoteComms.inhibitCycle := FALSE;
    RemoteComms.outputsFromBagger.printerDataReady := FALSE;
    RemoteComms.outputsFromBagger.runExternalExitConveyor := FALSE;
    RemoteComms.outputsFromBagger.heartbeatResponse := FALSE;

    RemoteComms.outputsFromBagger.baggerOK := FALSE;
    RemoteComms.inputsToBagger.bagGrabbed := FALSE;
    RemoteComms.outputsFromBagger.bagMade := FALSE;
    RemoteComms.outputsFromBagger.bagMadePlusLabelRequired := FALSE;
    RemoteComms.outputsFromBagger.cycleComplete := FALSE;
    //RemoteComms.outputsFromBagger.enableBagger := FALSE;
    RemoteComms.inputsToBagger.fillerOK := FALSE;
    RemoteComms.inputsToBagger.baggerInhibit := FALSE;
    RemoteComms.outputsFromBagger.readyForFiller := FALSE;
    RemoteComms.inputsToBagger.reverseConveyor := FALSE;
    RemoteComms.outputsFromBagger.waitingForPrinter := FALSE;

ELSE
    //		
    (* Inputs *)

    // Baggers not faults and heated up.
    baggerOK := NOT faultActive;

    // Filler is ready
    fillerOK := RemoteComms.inputsToBagger.fillerOK;

    // Active if either input is set to 'BaggerInhibit' and the corresponding input is active, or PAA enabled and inhibiting cycle.
    inhibitBagger := RemoteComms.inputsToBagger.baggerInhibit OR inhibitCycle;

    // Custom PRJ-22085: Robot successfully grabbed bag.
    bagGrabbed := RemoteComms.inputsToBagger.bagGrabbed;

    // Custom PRJ-59126: Reverse BEC when high
    reverseConveyor := RemoteComms.inputsToBagger.reverseConveyor;

    // Custom PRJ-MFT01: Enable Bagger (not used?
    //enableBagger := RemoteComms.enableBagger;

    (* Outputs *)
    // Cycle Complete
    IF state.head = HEAD_STATES.OpenedBag THEN
        _OutputPulse_CycleComplete.Trigger();
    END_IF

    // Bag Made
    IF state.head = HEAD_STATES.SealedAndSeparatedBag THEN
        _OutputPulse_BagMade.Trigger();
    END_IF

    RemoteComms.outputsFromBagger.readyForFiller := waitingForFiller;
    RemoteComms.outputsFromBagger.bagsLow := bagsLow;
    RemoteComms.outputsFromBagger.printerDataReady := printerDataReady;
    RemoteComms.outputsFromBagger.waitingForPrinter := state.sb.releaseFeed = RELEASE_FEED_STATES.WaitForPrinter;
    RemoteComms.outputsFromBagger.runExternalExitConveyor := runExitConveyor;

    // Bag Made Plus Label Required
    IF NOT printerDataReady AND state.head = HEAD_STATES.SealedAndSeparatedBag THEN
        RemoteComms.outputsFromBagger.bagMadePlusLabelRequired := TRUE;
    END_IF

    IF printerDataReady OR faultActive OR (state.sb.releaseFeed = RELEASE_FEED_STATES.FeedToOffset) THEN
        RemoteComms.outputsFromBagger.bagMadePlusLabelRequired := FALSE;
    END_IF

    // Heartbeat.
    // External device sets heartbeat bit and resets when it sees the same change from heartbeatResponse. 
    // If heartbeat stays on or off for too long set warning.
    _heartbeatWarningTimerOn(IN := RemoteComms.inputsToBagger.heartbeat AND HMIData.remoteCommsHeartbeatEnable);
    _heartbeatWarningTimerOff(IN := NOT RemoteComms.inputsToBagger.heartbeat AND HMIData.remoteCommsHeartbeatEnable);
    hmidata.remoteCommsHeartbeatLost.active := _heartbeatWarningTimerOn.Q OR _heartbeatWarningTimerOff.Q;
    RemoteComms.outputsFromBagger.heartbeatResponse := RemoteComms.inputsToBagger.heartbeat;

    //Fault Passing
    RemoteComms.outputsFromBagger.activeFaultsList := activeFaults;

END_IF