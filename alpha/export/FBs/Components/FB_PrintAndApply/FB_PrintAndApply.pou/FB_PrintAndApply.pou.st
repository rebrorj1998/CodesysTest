(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_PrintAndApply EXTENDS BaseComponentFB IMPLEMENTS IComponentStatus
VAR_INPUT
	baggerFaulted : BOOL;
	baggerInCycle : BOOL;
	bypass : BOOL;
	dataReady : BOOL;
	LOTAR : BOOL;
	faultInput : BOOL;
	PACycleComplete : BOOL;
	applicatorHome : BOOL;
	heartbeat : BOOL;
	productAtApplicatorSensor : BOOL;
	productAtExitSensor : BOOL;
	exitConveyorRunAfterPASetting : REAL;
	waitForPrinterFaultSetting : REAL;
	packageExitTimeSetting : REAL;
	packageToTampTimeSetting : REAL;
END_VAR
VAR_OUTPUT
	state : PRINT_AND_APPLY_STATES;
	commFail : BOOL;
	faultedStatus : BOOL;
	printerNotReady : BOOL;
	printerReadyToApply : BOOL;
	waitingForPrinter : BOOL;
	triggerOutput : BOOL;
	resetOutput : BOOL;
	inhibitCycle : BOOL;
	inhibitConveyor : BOOL;
	runConveyorAfterApply : BOOL;
	waitForPrintFault : BOOL;
	jammedFault : BOOL;
	clearOutBaggerIndicaiton : BOOL;
	packageFailedToExitFault : BOOL;
	packageFailedToReachTamp : BOOL;
	packageRemovedBeforeTamp : BOOL;
END_VAR
VAR
	resetOutputTimer : MonostableMultivibratorFB();
	triggerToPanther : DelayDwellFB() := (Dwellsetting := 750);
	exitConveyorRunAfterPA : DelayDwellFB() := (Dwellsetting := 3000);
	inCycleONS : FB_ONS;
	baggerFaultedONS : FB_ONS;
	faultedStatusONS : FB_ONS;
	_beginCycle : BOOL;
	_ackBaggerClear : BOOL;
	labelMightBePresent : BOOL;
	watchForBagExit : BOOL;
	watchForBagToTamp : BOOL;
	commFailTimer1 : Standard.TON := (PT := T#2S);
	commFailTimer2 : Standard.TON := (PT := T#2S);
	waitForPrinterFaultTimer : Standard.TON;
	packageFailedToExitTimer : TON;
	packageJammedAtExitTimer : TON;
	packageFailedToReachTampTimer : TON;
	productLeavingDebounce : TON := (PT := T#500MS);
	
END_VAR
	
VAR_IN_OUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: PrintAndApplyFB
//    Description: Statuses and Faults for print and apply
//    Created by: Ben Hess
//    Created Date: December 7th, 2020

// Run parent FB
SUPER^();

// Warnings to display on HMI
printerNotReady := faultedStatus OR commFail;
waitingForPrinter := (state = PRINT_AND_APPLY_STATES.WaitForLOTAR) OR (state = PRINT_AND_APPLY_STATES.WaitForLabel);

// Timeout on waiting for printer too long
waitForPrinterFaultTimer(IN := waitingForPrinter AND (waitForPrinterFaultSetting > 0) AND enable, 
							PT :=  TO_TIME(waitForPrinterFaultSetting * 1000.0),
							Q=> waitForPrintFault);

// Fault if package does not exit incline conveyor
packageFailedToExitTimer(IN := watchForBagExit AND (packageExitTimeSetting > 0) AND enable, 
							PT :=  TO_TIME(packageExitTimeSetting * 1000.0),
							Q=> );
							
packageJammedAtExitTimer(IN := productAtExitSensor AND (packageExitTimeSetting > 0) AND enable, 
							PT :=  T#10S,
							Q=> );							
// Fault if not reached tamp head by the time conveyor stops
packageFailedToReachTampTimer(IN := watchForBagToTamp AND (packageToTampTimeSetting > 0) AND enable, 
							PT :=  TO_TIME(packageToTampTimeSetting * 1000.0),
							Q=> );	

// When to watch for certain faults
IF watchForBagExit AND productAtExitSensor THEN
	watchForBagExit := FALSE;
END_IF
IF watchForBagToTamp AND productAtApplicatorSensor THEN
	watchForBagToTamp := FALSE;
END_IF

IF packageFailedToExitTimer.Q OR packageJammedAtExitTimer.Q OR packageFailedToReachTampTimer.Q THEN
	jammedFault := TRUE;
END_IF

// Set a flag is machine faults while a label might be present
labelMightBePresent := (state = PRINT_AND_APPLY_STATES.ReadyToApply) 
						OR (state = PRINT_AND_APPLY_STATES.WaitForLOTAR) 
						OR (state = PRINT_AND_APPLY_STATES.Applying);

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

// Run Exit conveyor after tamping
exitConveyorRunAfterPA.DwellSetting := TO_DINT(exitConveyorRunAfterPASetting * 1000.0);
exitConveyorRunAfterPA(Q => runConveyorAfterApply);

// Resetting logic
IF resetONS.Q THEN
	IF faultInput THEN
		resetOutputTimer.Trigger();
	END_IF
	IF NOT productAtApplicatorSensor THEN
		clearOutBaggerIndicaiton := FALSE;
	END_IF 
	watchForBagExit := FALSE;
	watchForBagToTamp := FALSE;
	packageFailedToExitFault := FALSE;
	jammedFault := FALSE;
	_beginCycle := FALSE;
	triggerToPanther.Reset();
	exitConveyorRunAfterPA.Reset();
	state := PRINT_AND_APPLY_STATES.Idle;
END_IF

IF NOT enable OR commFail OR faultedStatusONS.OSR OR baggerFaultedONS.OSR THEN
	state := PRINT_AND_APPLY_STATES.Fault;
END_IF

CASE state OF
		
	PRINT_AND_APPLY_STATES.Idle:			//  Wait for bagger cycle to begin
											inhibitConveyor := FALSE;
											inhibitCycle := FALSE;
											IF _beginCycle THEN
												_beginCycle := FALSE;
												watchForBagToTamp := TRUE;
												state := PRINT_AND_APPLY_STATES.WaitForLOTAR;
											END_IF
	
											
	PRINT_AND_APPLY_STATES.WaitForLOTAR:	// Wait for LOTAR from Panther. Add delay to allow for accel on conveyor if stopped, otherwise package can sail right through
											IF LOTAR THEN
												IF NOT productAtApplicatorSensor THEN
													triggerToPanther.DelaySetting := 0;
												END_IF
												state := PRINT_AND_APPLY_STATES.ReadyToApply;
											END_IF
											
											IF productAtApplicatorSensor THEN
												triggerToPanther.DelaySetting := 250;
												watchForBagToTamp := FALSE;
												inhibitConveyor := TRUE;
											END_IF
											inhibitCycle := TRUE;
	
	PRINT_AND_APPLY_STATES.ReadyToApply:	// If package is seen, trigger Print and Apply
											inhibitConveyor := FALSE;
											IF productAtApplicatorSensor THEN
												inhibitCycle := FALSE;
												exitConveyorRunAfterPA.Trigger();
												triggerToPanther.Trigger();
												watchForBagToTamp := FALSE;
												state := PRINT_AND_APPLY_STATES.Applying;
											END_IF
											
											
	
	PRINT_AND_APPLY_STATES.Applying:		//  Allow for a debounce on package leaving the photoeye
											IF productLeavingDebounce.Q THEN
												watchForBagExit := TRUE;
												state := PRINT_AND_APPLY_STATES.Idle;
											END_IF
										
	PRINT_AND_APPLY_STATES.Fault:			//
											inhibitConveyor := FALSE;
											inhibitCycle := FALSE;
											watchForBagExit := FALSE;
											watchForBagToTamp := FALSE;
											packageFailedToExitFault := FALSE;
											packageFailedToReachTamp := FALSE;
											packageRemovedBeforeTamp := FALSE;
											exitConveyorRunAfterPA.Reset();
											triggerToPanther.Reset();
											
END_CASE

// Product leaving rear exit conveyor debounce
productLeavingDebounce(IN := (NOT productAtApplicatorSensor) AND state = PRINT_AND_APPLY_STATES.Applying);

printerReadyToApply := state = PRINT_AND_APPLY_STATES.ReadyToApply;

// Comms heartbeat for comm fail fault
commFailTimer1(IN := enable AND heartbeat);
commFailTimer2(IN := enable AND NOT heartbeat);
commFail := commFailTimer1.Q OR commFailTimer2.Q;

// Faulted status from Print and Apply
faultedStatus := NOT commFail AND NOT iPAFaulted AND enable;