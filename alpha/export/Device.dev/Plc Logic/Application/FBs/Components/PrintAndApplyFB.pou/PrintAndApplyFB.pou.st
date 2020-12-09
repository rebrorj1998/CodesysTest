(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK PrintAndApplyFB EXTENDS BaseComponentFB IMPLEMENTS IComponentStatus
VAR_INPUT
	baggerFaulted : BOOL;
	baggerInCycle : BOOL;
	dataReady : BOOL;
	LOTAR : BOOL;
	PACycleComplete : BOOL;
	applicatorHome : BOOL;
	heartbeat : BOOL;
	productSensor : BOOL;
END_VAR
VAR_OUTPUT
	state : PRINT_AND_APPLY_STATES;
	commFail : FB_Fault(name := 'Comm Fail');
	faultedStatus : FB_Fault(name := 'Print and Apply Faulted');
	printerNotReady : BOOL;
	printerReadyToApply : BOOL;
	waitingForPrinter : BOOL;
	triggerOutput : BOOL;
	inhibitCycle : BOOL;
	inhibitConveyor : BOOL;
END_VAR
VAR
	resetOutputTimer : MonostableMultivibratorFB();
	
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

printerNotReady := baggerFaulted OR commFail.active;
waitingForPrinter := (state = PRINT_AND_APPLY_STATES.WaitForLOTAR) OR (state = PRINT_AND_APPLY_STATES.WaitForLabel);
inhibitCycle := (state <> PRINT_AND_APPLY_STATES.Idle) AND enable;

resetOutputTimer.DwellSetting := 500;
resetOutputTimer();
IF resetONS.Q THEN
	resetOutputTimer.Trigger();
	state := PRINT_AND_APPLY_STATES.Idle;
END_IF
IF NOT enable OR baggerFaulted OR commFail.active OR faultedStatus.active THEN
	state := PRINT_AND_APPLY_STATES.Fault;
END_IF

CASE state OF
		
	PRINT_AND_APPLY_STATES.Idle:			//  
											triggerOutput := FALSE;
											inhibitConveyor := FALSE;
											inhibitCycle := FALSE;
											IF baggerInCycle THEN
												IF dataReady THEN
													state := PRINT_AND_APPLY_STATES.WaitForLOTAR;
												ELSE
													state := PRINT_AND_APPLY_STATES.WaitForLabel;
												END_IF
											END_IF
	
	
	PRINT_AND_APPLY_STATES.WaitForLabel:	//  
											IF dataReady OR LOTAR THEN
												state := PRINT_AND_APPLY_STATES.WaitForLOTAR;
											END_IF
											inhibitConveyor := productSensor;
											inhibitCycle := TRUE;
											
	PRINT_AND_APPLY_STATES.WaitForLOTAR:	//
											IF LOTAR THEN
												state := PRINT_AND_APPLY_STATES.ReadyToApply;
											END_IF
											inhibitConveyor := productSensor;
											inhibitCycle := TRUE;
	
	PRINT_AND_APPLY_STATES.ReadyToApply:	//
											inhibitConveyor := FALSE;
											inhibitCycle := FALSE;
											IF productSensor THEN
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
											
	

END_CASE

printerReadyToApply := state = PRINT_AND_APPLY_STATES.ReadyToApply;