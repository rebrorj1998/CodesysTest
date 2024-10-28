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

_OutputPulse_CycleComplete(Q => RemoteComms.OPCOutputsFromBagger.cycleComplete);
_outputPulse_CycleComplete.DwellSetting := 500;
_OutputPulse_BagMade(Q => RemoteComms.OPCOutputsFromBagger.bagMade);
_OutputPulse_BagMade.DwellSetting := 500;

IF NOT HMIData.auxIOSource.OPC_UA THEN
    // Turn OPC outputs off
    RemoteComms.OPCOutputsFromBagger.bagsLow := FALSE;
    RemoteComms.OPCOutputsFromBagger.printerDataReady := FALSE;
    RemoteComms.OPCOutputsFromBagger.runExternalExitConveyor := FALSE;
    RemoteComms.OPCOutputsFromBagger.heartbeatResponse := FALSE;
    RemoteComms.OPCOutputsFromBagger.baggerOK := FALSE;
    RemoteComms.OPCInputsToBagger.bagGrabbed := FALSE;
    RemoteComms.OPCOutputsFromBagger.bagMade := FALSE;
    RemoteComms.OPCOutputsFromBagger.bagMadePlusLabelRequired := FALSE;
    RemoteComms.OPCOutputsFromBagger.cycleComplete := FALSE;
    RemoteComms.OPCInputsToBagger.fillerOK := FALSE;
    RemoteComms.OPCInputsToBagger.baggerInhibit := FALSE;
    RemoteComms.OPCOutputsFromBagger.readyForFiller := FALSE;
    RemoteComms.OPCInputsToBagger.reverseConveyor := FALSE;
    RemoteComms.OPCOutputsFromBagger.waitingForPrinter := FALSE;

	ELSIF NOT HMIData.auxIOSource.ModbusTCP THEN
	// Turn modbus outputs off
	RemoteComms.modbusOutputsFromBagger.bagsLow := FALSE;
    RemoteComms.modbusOutputsFromBagger.printerDataReady := FALSE;
    RemoteComms.modbusOutputsFromBagger.runExternalExitConveyor := FALSE;
    RemoteComms.modbusOutputsFromBagger.heartbeatResponse := FALSE;
    RemoteComms.modbusOutputsFromBagger.baggerOK := FALSE;
    RemoteComms.modbusInputsToBagger.bagGrabbed := FALSE;
    RemoteComms.modbusOutputsFromBagger.bagMade := FALSE;
    RemoteComms.modbusOutputsFromBagger.bagMadePlusLabelRequired := FALSE;
    RemoteComms.modbusOutputsFromBagger.cycleComplete := FALSE;
    RemoteComms.modbusInputsToBagger.baggerInhibit := FALSE;
    RemoteComms.modbusOutputsFromBagger.readyForFiller := FALSE;
    RemoteComms.modbusInputsToBagger.reverseConveyor := FALSE;
    RemoteComms.modbusOutputsFromBagger.waitingForPrinter := FALSE;
    //	
END_IF	


IF HMIData.auxIOSource.OPC_UA THEN
    (* Inputs *)	
    // Baggers not faults and heated up.
    RemoteComms.modbusOutputsFromBagger.baggerOK := RemoteComms.OPCOutputsFromBagger.baggerOK := NOT faultActive;	

    // Filler is ready
    fillerOK := RemoteComms.OPCInputsToBagger.fillerOK;

    // Active if either input is set to 'BaggerInhibit' and the corresponding input is active, or PAA enabled and inhibiting cycle.
    inhibitBagger := RemoteComms.OPCInputsToBagger.baggerInhibit OR inhibitCycle;

    // Custom PRJ-22085: Robot successfully grabbed bag.
    bagGrabbed := RemoteComms.OPCInputsToBagger.bagGrabbed;

    // Custom PRJ-59126: Reverse BEC when high
    reverseConveyor := RemoteComms.OPCInputsToBagger.reverseConveyor;

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

    RemoteComms.OPCOutputsFromBagger.readyForFiller := waitingForFiller;
    RemoteComms.OPCOutputsFromBagger.bagsLow := bagsLow;
    RemoteComms.OPCOutputsFromBagger.printerDataReady := printerDataReady;
    RemoteComms.OPCOutputsFromBagger.waitingForPrinter := state.sb.releaseFeed = RELEASE_FEED_STATES.WaitForPrinter;
    RemoteComms.OPCOutputsFromBagger.runExternalExitConveyor := runExitConveyor;

    // Bag Made Plus Label Required
    IF NOT printerDataReady AND state.head = HEAD_STATES.SealedAndSeparatedBag THEN
        RemoteComms.OPCOutputsFromBagger.bagMadePlusLabelRequired := TRUE;
    END_IF

    IF printerDataReady OR faultActive OR (state.sb.releaseFeed = RELEASE_FEED_STATES.FeedToOffset) THEN
        RemoteComms.OPCOutputsFromBagger.bagMadePlusLabelRequired := FALSE;
    END_IF

    // Heartbeat.
    // External device sets heartbeat bit and resets when it sees the same change from heartbeatResponse. 
    // If heartbeat stays on or off for too long set warning.
    _heartbeatWarningTimerOn(IN := RemoteComms.OPCInputsToBagger.heartbeat AND HMIData.remoteCommsHeartbeatEnable);
    _heartbeatWarningTimerOff(IN := NOT RemoteComms.OPCInputsToBagger.heartbeat AND HMIData.remoteCommsHeartbeatEnable);
    hmidata.remoteCommsHeartbeatLost.active := _heartbeatWarningTimerOn.Q OR _heartbeatWarningTimerOff.Q;
    RemoteComms.OPCOutputsFromBagger.heartbeatResponse := RemoteComms.OPCInputsToBagger.heartbeat;

    //Fault Passing
    RemoteComms.OPCOutputsFromBagger.activeFaultsList := activeFaults;
	
END_IF



IF HMIData.auxIOSource.ModbusTCP THEN
    (* Inputs *)	
    // Baggers not faults and heated up.
    RemoteComms.modbusOutputsFromBagger.baggerOK := RemoteComms.modbusOutputsFromBagger.baggerOK := NOT faultActive;	

    // Filler is ready
    fillerOK := RemoteComms.modbusInputsToBagger.fillerOK;

    // Active if either input is set to 'BaggerInhibit' and the corresponding input is active, or PAA enabled and inhibiting cycle.
    inhibitBagger := RemoteComms.modbusInputsToBagger.baggerInhibit OR inhibitCycle;

    // Custom PRJ-22085: Robot successfully grabbed bag.
    bagGrabbed := RemoteComms.modbusInputsToBagger.bagGrabbed;

    // Custom PRJ-59126: Reverse BEC when high
    reverseConveyor := RemoteComms.modbusInputsToBagger.reverseConveyor;

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

    RemoteComms.modbusOutputsFromBagger.readyForFiller := waitingForFiller;
    RemoteComms.modbusOutputsFromBagger.bagsLow := bagsLow;
    RemoteComms.modbusOutputsFromBagger.printerDataReady := printerDataReady;
    RemoteComms.modbusOutputsFromBagger.waitingForPrinter := state.sb.releaseFeed = RELEASE_FEED_STATES.WaitForPrinter;
    RemoteComms.modbusOutputsFromBagger.runExternalExitConveyor := runExitConveyor;

    // Bag Made Plus Label Required
    IF NOT printerDataReady AND state.head = HEAD_STATES.SealedAndSeparatedBag THEN
        RemoteComms.modbusOutputsFromBagger.bagMadePlusLabelRequired := TRUE;
    END_IF

    IF printerDataReady OR faultActive OR (state.sb.releaseFeed = RELEASE_FEED_STATES.FeedToOffset) THEN
        RemoteComms.modbusOutputsFromBagger.bagMadePlusLabelRequired := FALSE;
    END_IF

    // Heartbeat.
    // External device sets heartbeat bit and resets when it sees the same change from heartbeatResponse. 
    // If heartbeat stays on or off for too long set warning.
    _heartbeatWarningTimerOn(IN := RemoteComms.modbusInputsToBagger.heartbeat AND HMIData.remoteCommsHeartbeatEnable);
    _heartbeatWarningTimerOff(IN := NOT RemoteComms.modbusInputsToBagger.heartbeat AND HMIData.remoteCommsHeartbeatEnable);
    hmidata.remoteCommsHeartbeatLost.active := _heartbeatWarningTimerOn.Q OR _heartbeatWarningTimerOff.Q;
    RemoteComms.modbusOutputsFromBagger.heartbeatResponse := RemoteComms.modbusInputsToBagger.heartbeat;

      
	
END_IF