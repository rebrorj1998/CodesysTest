(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_Filler EXTENDS FB_BaseComponent IMPLEMENTS IComponentStatus
VAR_INPUT
	inCycle : BOOL;
	faultActive : BOOL;
	baggerInhibited : BOOL;
	fillerTrigger : BOOL;
	activateFiller : BOOL;
	fillerOK : BOOL;
	dropTime : REAL;
END_VAR
VAR_OUTPUT
	state : FILLER_STATES;
	droppingProduct : BOOL;
	fillerModeActive : BOOL;
	waitingForFiller : BOOL;
	cycleBagRequest : BOOL;
	cycleBaggerToActivateFiller : Warning;
	notReady : FB_Fault(name := 'Not Ready');
END_VAR
VAR
	_baggerCycleInitiated : BOOL;
    _baggerCycledAndReady : BOOL;
	_fillerRequestedCycle : BOOL;
	_fillerTrigONS : FB_ONS;
	dropTimer : Standard.TON;
END_VAR
	
VAR_IN_OUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: FillerFB
//    Description: Filler state machine
//    Created by: Ben Hess
//    Created Date: October 16th, 2019

SUPER^();

dropTimer(PT := TO_TIME(dropTime * 1000));
IF resetONS.Q OR HMIData.faultActive OR NOT enable OR NOT activateFiller THEN
	state := FILLER_STATES.Idle;
	cycleBagRequest := FALSE;
	waitingForFiller := FALSE;
	cycleBaggerToActivateFiller.active := FALSE;
	_fillerRequestedCycle := FALSE;
	_baggerCycledAndReady := FALSE;
	_baggerCycleInitiated := FALSE;
	dropTimer.IN := FALSE;
END_IF

//
_fillerTrigONS(CLK := fillerTrigger);
IF _fillerTrigONS.OSR THEN
	_fillerRequestedCycle := TRUE;
END_IF

CASE state OF
	FILLER_STATES.Idle :							IF (activateFiller AND enable) AND NOT inCycle AND NOT HMIData.faultActive THEN
														state := FILLER_STATES.CycleBaggerToActiveFiller;
													END_IF
	
	FILLER_STATES.CycleBaggerToActiveFiller :		// Operator must cycle a bag out first to guarentee bag open and ready for filler
		// Operator must cycle a bag out first to guarentee bag open and ready for filler
													cycleBaggerToActivateFiller.active := TRUE;
													IF _baggerCycledAndReady THEN
														cycleBaggerToActivateFiller.active := FALSE;
														_baggerCycleInitiated := FALSE;
														_baggerCycledAndReady := FALSE;
			_fillerRequestedCycle := FALSE;
														state := FILLER_STATES.WaitingForFiller;
													END_IF
	
	FILLER_STATES.WaitingForFiller :				// Waiting for filler trigger to initiate cycle
		// Waiting for filler trigger to initiate cycle
													waitingForFiller := TRUE;
		IF _fillerRequestedCycle THEN
														waitingForFiller := FALSE;
														_fillerRequestedCycle := FALSE;
														state := FILLER_STATES.Dropping;
													END_IF
													
	FILLER_STATES.Dropping :						// Filler is dropping product
													dropTimer.IN := TRUE;
													IF dropTimer.Q THEN
														IF NOT HMIData.baggerInhibited.active THEN
															dropTimer.IN := FALSE;
															cycleBagRequest := TRUE;
			_fillerRequestedCycle := FALSE;
			_baggerCycledAndReady := FALSE;
															state := FILLER_STATES.BaggerCycling;	
														END_IF
													END_IF
	
	FILLER_STATES.BaggerCycling :					// Wait for bag to open 
		// Wait for bag to open 
													IF _baggerCycleInitiated THEN
														_baggerCycleInitiated := FALSE;
														cycleBagRequest := FALSE;
													END_IF
													
													IF _baggerCycledAndReady THEN
														_baggerCycledAndReady := FALSE;
														state := FILLER_STATES.WaitingForFiller;
													END_IF
END_CASE