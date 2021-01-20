(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK PrintAndApplyFB EXTENDS BaseComponentFB IMPLEMENTS IComponentStatus
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
	productSensor : BOOL;
	exitConveyorRunAfterPASetting : REAL;
	waitForPrinterFaultSetting : REAL;
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
END_VAR
VAR
	resetOutputTimer : MonostableMultivibratorFB();
	exitConveyorRunAfterPA : DelayDwellFB() := (Dwellsetting := 3000);
	inCycleONS : FB_ONS;
	baggerFaultedONS : FB_ONS;
	faultedStatusONS : FB_ONS;
	_beginCycle : BOOL;
	commFailTimer1 : Standard.TON := (PT := T#2S);
	commFailTimer2 : Standard.TON := (PT := T#2S);
	waitForPrinterFaultTimer : Standard.TON;
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

printerNotReady := baggerFaulted OR commFail;
waitingForPrinter := (state = PRINT_AND_APPLY_STATES.WaitForLOTAR) OR (state = PRINT_AND_APPLY_STATES.WaitForLabel);


// Timeout on waiting for printer too long
waitForPrinterFaultTimer(IN := waitingForPrinter AND (waitForPrinterFaultSetting > 0) AND enable, 
							PT :=  TO_TIME(waitForPrinterFaultSetting * 1000.0),
							Q=> waitForPrintFault);

//inhibitCycle := (state <> PRINT_AND_APPLY_STATES.Idle) AND enable;
inCycleONS(CLK := baggerInCycle);
baggerFaultedONS(CLK := baggerFaulted);
faultedStatusONS(CLK := faultedStatus);
// Send reset output pulse
resetOutputTimer.DwellSetting := 500;
resetOutputTimer(Q => resetOutput);

exitConveyorRunAfterPA.DwellSetting := TO_DINT(exitConveyorRunAfterPASetting * 1000.0);
exitConveyorRunAfterPA(Q => runConveyorAfterApply);

IF resetONS.Q THEN
	IF faultInput THEN
		resetOutputTimer.Trigger();
	END_IF
	_beginCycle := FALSE;
	exitConveyorRunAfterPA.Reset();
	state := PRINT_AND_APPLY_STATES.Idle;
END_IF
IF NOT enable OR commFail OR faultedStatusONS.OSR OR baggerFaultedONS.OSR THEN
	state := PRINT_AND_APPLY_STATES.Fault;
END_IF

CASE state OF
		
	PRINT_AND_APPLY_STATES.Idle:			//  
											triggerOutput := FALSE;
											inhibitConveyor := FALSE;
											inhibitCycle := FALSE;
											IF _beginCycle THEN
												_beginCycle := FALSE;
												IF dataReady THEN
													state := PRINT_AND_APPLY_STATES.WaitForLOTAR;
												ELSIF LOTAR THEN
													state := PRINT_AND_APPLY_STATES.ReadyToApply;
												ELSE
													state := PRINT_AND_APPLY_STATES.WaitForLabel;
												END_IF
											END_IF
	
	
	PRINT_AND_APPLY_STATES.WaitForLabel:	//  
											IF dataReady OR LOTAR THEN
												state := PRINT_AND_APPLY_STATES.WaitForLOTAR;
											END_IF
											IF productSensor THEN
												inhibitConveyor := TRUE;
											END_IF
											
											inhibitCycle := TRUE;
											
	PRINT_AND_APPLY_STATES.WaitForLOTAR:	//
											IF LOTAR THEN
												state := PRINT_AND_APPLY_STATES.ReadyToApply;
											END_IF
											IF productSensor THEN
												inhibitConveyor := TRUE;
											END_IF
											inhibitCycle := TRUE;
	
	PRINT_AND_APPLY_STATES.ReadyToApply:	//
											inhibitConveyor := FALSE;
											inhibitCycle := FALSE;
											IF productSensor THEN
												exitConveyorRunAfterPA.Trigger();
												triggerOutput := TRUE;
												state := PRINT_AND_APPLY_STATES.Applying;
											END_IF
											
											
	
	PRINT_AND_APPLY_STATES.Applying:		//
											inhibitCycle := FALSE;
											IF NOT productSensor THEN
												triggerOutput := FALSE;
												state := PRINT_AND_APPLY_STATES.Idle;
											END_IF
										
	PRINT_AND_APPLY_STATES.Fault:			//
											triggerOutput := FALSE;
											inhibitConveyor := FALSE;
											inhibitCycle := FALSE;
											exitConveyorRunAfterPA.Reset();
	

END_CASE

printerReadyToApply := state = PRINT_AND_APPLY_STATES.ReadyToApply;

// Comms heartbeat for comm fail fault
commFailTimer1(IN := enable AND heartbeat);
commFailTimer2(IN := enable AND NOT heartbeat);
commFail := commFailTimer1.Q OR commFailTimer2.Q;

// Faulted status from Print and Apply
faultedStatus := NOT commFail AND NOT iPAFaulted AND enable;