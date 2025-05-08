(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_PrintAndApply EXTENDS FB_BaseComponent IMPLEMENTS IComponentStatus
VAR_INPUT
	tampDelayWithLOTAR : REAL;
	tampDelayWithoutLOTAR : REAL;
	packageAtExitSensor : BOOL;
	inhibitOnTamp : BOOL;
	uninhibit : BOOL;
	exemptFaultsActive : BOOL;
	pressureBarObstruction : BOOL;
	baggerFaulted : BOOL;
	baggerInCycle : BOOL;
	bypass : BOOL;
	dataReady : BOOL;
	LOTAR : BOOL;
	printerFaulted : BOOL;
	PACycleComplete : BOOL;
	applicatorHome : BOOL;
	heartbeat : BOOL;
	productAtApplicatorSensor : BOOL;
	//inclineConveyorRunning : BOOL;
	exitConveyorRunAfterPASetting : REAL;
	waitForPrinterFaultSetting : REAL;
	packageExitTimeSetting : REAL;
	packageToTampTimeSetting : REAL;
END_VAR
VAR_OUTPUT
	state : PRINT_AND_APPLY_STATES;
	commFail : BOOL;
	faultedStatus : BOOL;
	waitingForPackage : BOOL;
	printerNotReady : BOOL;
	printerReadyToApply : BOOL;
	packageWasTamped : BOOL;
	waitingForPrinter : BOOL;
	triggerOutput : BOOL;
	resetOutput : BOOL;
	inhibitCycle : BOOL;
	inhibitConveyor : BOOL;
	runConveyorAfterApply : BOOL;
	waitForPrintFault : BOOL;
	jammedFault : BOOL;
	LOTARFault : BOOL;
	clearOutBaggerIndicaiton : BOOL;
	packageFailedToExitFault : BOOL;
	packageFailedToReachTamp : BOOL;
	packageRemovedBeforeTamp : BOOL;
	productLeavingDebounce : Standard.TON := (PT := T#300MS);
	labelsInQueue : BOOL;
END_VAR
VAR 
	_LOTARONS : FB_ONS;
	_packageSensorONS : FB_ONS;
	_monitorLabelOnTamp : BOOL;
	_labelOffTampDebounceTimer : Standard.TON := (PT := T#500MS);
	_pantherTriggerDelay : INT := 0;
	_packageTampSensorFlag : BOOL;
	resetOutputTimer : FB_MonostableMultivibrator();
	triggerToPanther : DelayDwellFB() := (Dwellsetting := 1000);
	exitConveyorRunAfterPA : DelayDwellFB() := (Dwellsetting := 3000);
	inCycleONS : FB_ONS;
	baggerFaultedONS : FB_ONS;
	faultedStatusONS : FB_ONS;
	_beginCycle : BOOL;
	_ackBaggerClear : BOOL;
	labelMightBePresent : BOOL;
	watchForBagExit : BOOL;
	watchForBagToTamp : BOOL;
	packageWasSeen : BOOL;
	commFailTimer1 : Standard.TON := (PT := T#2S);
	commFailTimer2 : Standard.TON := (PT := T#2S);
	waitForPrinterFaultTimer : Standard.TON;
	packageFailedToExitTimer : Standard.TON;
	packageFailedToReachTampTimer : Standard.TON;
	inhibitCycleOffDelay : TON := (PT := T#400MS);
	labelsInQueueFaultTimer : Standard.TON := (PT := T#5S);
	_uninhibitONS : FB_ONS;
	tamp_ton: Ton;
	tmr_store_index: INT;
	tamp_time_array: ARRAY[0..10] OF TIME;
END_VAR	

(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: PrintAndApplyFB
//    Description: Statuses and Faults for print and apply
//    Created by: Ben Hess
//    Created Date: December 7th, 2020

SUPER^();

tamp_ton(PT:=T#500S);
IF _packageSensorONS.OSR AND iPAApplicatorHome THEN
	tamp_ton.IN := TRUE;
ELSIF  NOT iPAApplicatorHome AND tamp_ton.in THEN
	tamp_time_array[tmr_store_index]:= tamp_ton.ET;
	tamp_ton.IN := FALSE;	
	IF tmr_store_index < 10 THEN
		tmr_store_index := tmr_store_index +1;
	ELSE
		tmr_store_index:=0;
	END_IF
END_IF


// If Monitoring Vacuum and the debounce is complete, Fault.
_labelOffTampDebounceTimer(	
	IN := _monitorLabelOnTamp AND NOT LOTAR,
	Q => LOTARFault
);

// When LOTAR goes high begin monitoring label on tamp head
_LOTARONS(CLK := iPALOTAR);
IF _LOTARONS.OSR THEN
	_monitorLabelOnTamp := TRUE;
END_IF
_packageSensorONS(CLK := productAtApplicatorSensor);

// Warnings to display on HMI
printerNotReady := faultedStatus OR commFail;
waitingForPrinter := ((state = PRINT_AND_APPLY_STATES.WaitForLOTAR) OR (state = PRINT_AND_APPLY_STATES.WaitForLabel));

// Timeout on waiting for printer too long
waitForPrinterFaultTimer(
	IN := waitingForPrinter AND (waitForPrinterFaultSetting > 0) AND enable, 
	PT := TO_TIME(waitForPrinterFaultSetting * 1000.0),
	 Q => waitForPrintFault
);

// Fault if package does not exit incline conveyor
packageFailedToExitTimer(
	IN := watchForBagExit AND (packageExitTimeSetting > 0) AND enable, 
	PT :=  TO_TIME(packageExitTimeSetting * 1000.0)
);
												
// Fault if not reached tamp head by the time conveyor stops
packageFailedToReachTampTimer(
	IN := watchForBagToTamp AND (packageToTampTimeSetting > 0) AND enable, 
	PT :=  TO_TIME(packageToTampTimeSetting * 1000.0)
);

// Fault if label is in queue for too long
labelsInQueueFaultTimer(IN := dataReady AND enable, 
						Q => labelsInQueue);	
			
//				
IF watchForBagExit AND packageAtExitSensor THEN
	watchForBagExit := FALSE;
END_IF
				
//	
IF watchForBagToTamp AND productAtApplicatorSensor THEN
	watchForBagToTamp := FALSE;
END_IF

//
IF NOT productAtApplicatorSensor THEN
	_packageTampSensorFlag := FALSE;
END_IF

//
jammedFault := packageFailedToExitTimer.Q OR packageFailedToReachTampTimer.Q;

// Set a flag is machine faults while a label might be present
labelMightBePresent := (state = PRINT_AND_APPLY_STATES.ReadyToApply) 
					OR (state = PRINT_AND_APPLY_STATES.WaitForLOTAR) 
					OR (state = PRINT_AND_APPLY_STATES.Applying)
					OR dataReady;
						
// Displays as a pop-up on HMI
IF ((baggerFaulted AND labelMightBePresent) OR faultedStatusONS.OSR) AND enable THEN
	clearOutBaggerIndicaiton := TRUE;
END_IF

// Ack from operator screen that bagger has been cleared out
IF _ackBaggerClear THEN
	// Only clear flag if product sensor on conveyor is clear
	IF NOT productAtApplicatorSensor THEN
		clearOutBaggerIndicaiton := FALSE;
	END_IF 
	_ackBaggerClear := FALSE;
END_IF

// One shots
inCycleONS(CLK := baggerInCycle);
baggerFaultedONS(CLK := baggerFaulted);
faultedStatusONS(CLK := faultedStatus);

// Send reset output pulse
resetOutputTimer.DwellSetting := 500;
resetOutputTimer(Q => resetOutput);

// Run trigger delay/dwell
triggerToPanther(Q => triggerOutput);

// 
_uninhibitONS(CLK := uninhibit);
IF _uninhibitONS.OSR AND state = PRINT_AND_APPLY_STATES.Inhibited THEN
	state := PRINT_AND_APPLY_STATES.Idle;
END_IF

// Run Exit conveyor after tamping
exitConveyorRunAfterPA.DwellSetting := TO_DINT(exitConveyorRunAfterPASetting * 1000.0);
exitConveyorRunAfterPA(Q => runConveyorAfterApply);

// Resetting logic
IF resetONS.Q THEN
	_beginCycle := FALSE;
	_monitorLabelOnTamp := FALSE;
	IF printerFaulted OR baggerFaulted AND NOT exemptFaultsActive THEN
		resetOutputTimer.Trigger();
	END_IF
	IF NOT productAtApplicatorSensor THEN
		clearOutBaggerIndicaiton := FALSE;
	END_IF 
	watchForBagExit := FALSE;
	watchForBagToTamp := FALSE;
	waitingForPackage := FALSE;
	packageWasTamped := FALSE;
	packageFailedToExitFault := FALSE;
	packageWasSeen := FALSE;
	triggerToPanther.Reset();
	exitConveyorRunAfterPA.Reset();
	state := PRINT_AND_APPLY_STATES.Idle;
END_IF

//
IF commFail OR faultedStatusONS.OSR OR baggerFaultedONS.OSR OR NOT enable THEN
	state := PRINT_AND_APPLY_STATES.Fault;
END_IF

//
productLeavingDebounce();

//
inhibitCycleOffDelay(IN := NOT (state = PRINT_AND_APPLY_STATES.Applying));

//
CASE state OF
	PRINT_AND_APPLY_STATES.Idle:			// Wait for bagger cycle to begin
											inhibitConveyor := FALSE;
											packageWasSeen := FALSE;
											packageWasTamped := FALSE;
											productLeavingDebounce.IN := FALSE;
											inhibitCycle := FALSE;
											
											IF _beginCycle THEN
												_beginCycle := FALSE;
												watchForBagToTamp := TRUE;
												waitingForPackage := TRUE;
												state := PRINT_AND_APPLY_STATES.WaitForLOTAR;
											END_IF
											
	PRINT_AND_APPLY_STATES.WaitForLOTAR:	// Wait for LOTAR from Panther. Add delay to allow for accel on conveyor if stopped, otherwise package can sail right through
											inhibitCycle := TRUE;
											IF iPALOTAR THEN
												IF NOT productAtApplicatorSensor AND NOT packageWasSeen THEN
													triggerToPanther.DelaySetting := TO_DINT(tampDelayWithLOTAR * 1000);
												END_IF
												state := PRINT_AND_APPLY_STATES.ReadyToApply;
												inhibitCycle := FALSE;
											END_IF
											IF _packageSensorONS.OSR THEN
												triggerToPanther.DelaySetting := TO_DINT(tampDelayWithoutLOTAR * 1000);
												watchForBagToTamp := FALSE;
												inhibitConveyor := TRUE;
												packageWasSeen := TRUE;
											END_IF
	
	PRINT_AND_APPLY_STATES.ReadyToApply:	// If package is seen, trigger Print and Apply
											inhibitConveyor := FALSE;
											IF inhibitOnTamp THEN
												inhibitCycle := TRUE;
											END_IF
											IF (_packageSensorONS.OSR AND NOT _packageTampSensorFlag) OR packageWasSeen THEN
												packageWasSeen := FALSE;
												watchForBagToTamp := FALSE;
												waitingForPackage := FALSE;
												triggerToPanther.Trigger();
												exitConveyorRunAfterPA.Trigger();
												state := PRINT_AND_APPLY_STATES.Applying;
											END_IF
											
	PRINT_AND_APPLY_STATES.Applying:		// Allow for a debounce on package leaving the photoeye
											_monitorLabelOnTamp := FALSE;
											productLeavingDebounce.IN := TRUE;
											IF productLeavingDebounce.Q THEN
												productLeavingDebounce.IN := FALSE;
												HMIData.printerCycles.Increment();
												IF NOT inhibitOnTamp THEN
													inhibitCycle := FALSE;
													watchForBagExit := TRUE;
													state := PRINT_AND_APPLY_STATES.Idle;
												ELSE
													inhibitCycle := TRUE;
													inhibitConveyor := TRUE;
													exitConveyorRunAfterPA.ManualOff();
													state := PRINT_AND_APPLY_STATES.Inhibited;
													IF productAtApplicatorSensor THEN
														_packageTampSensorFlag := TRUE;
													END_IF
												END_IF
											END_IF
											packageWasTamped := TRUE;
											
	PRINT_AND_APPLY_STATES.Inhibited:		//
											IF _uninhibitONS.OSR THEN
												state := PRINT_AND_APPLY_STATES.Idle;
											END_IF
											
	PRINT_AND_APPLY_STATES.Fault:			//
											_monitorLabelOnTamp := FALSE;
											inhibitConveyor := FALSE;
											inhibitCycle := FALSE;
											watchForBagExit := FALSE;
											watchForBagToTamp := FALSE;
											packageFailedToExitFault := FALSE;
											packageFailedToReachTamp := FALSE;
											packageRemovedBeforeTamp := FALSE;
											packageWasTamped := FALSE;
											waitingForPackage := FALSE;
											packageWasSeen := FALSE;
											productLeavingDebounce.IN := FALSE;
											exitConveyorRunAfterPA.Reset();
											triggerToPanther.Reset();								
END_CASE

//
printerReadyToApply := state = PRINT_AND_APPLY_STATES.ReadyToApply;

// Comms heartbeat for comm fail fault
commFailTimer1(IN := enable AND heartbeat);
commFailTimer2(IN := enable AND NOT heartbeat);
commFail := commFailTimer1.Q OR commFailTimer2.Q;

// Faulted status from Print and Apply
faultedStatus := ((NOT commFail AND NOT iPAFaulted) OR LOTARFault) AND enable;