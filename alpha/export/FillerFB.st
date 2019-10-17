

FUNCTION_BLOCK FillerFB EXTENDS BaseComponentFB IMPLEMENTS IComponentStatus
VAR_INPUT
	fillerTrigger : BOOL;
	activateFiller : BOOL;
	fillerOK : BOOL;
	dropTime : REAL;
END_VAR
VAR_OUTPUT
	state : FILLER_STATES;
	fillerModeActive : BOOL;
	waitingForFiller : BOOL;
	cycleBagRequest : BOOL;
	cycleBaggerToActivateFiller : Warning;
	notReady : FB_Fault(name := 'Not Ready');
END_VAR
VAR
	_baggerCycleInitiated : BOOL;
    _baggerCycledAndReady : BOOL;
	fillerRequestedCycle : BOOL;
	fillerTrigONS : FB_ONS;
	dropTimer : Standard.TON;
END_VAR
	
VAR_IN_OUT
END_VAR

//    Function Block: FillerFB
//    Description: Filler state machine
//    Created by: Ben Hess
//    Created Date: October 16th, 2019
SUPER^();
dropTimer(PT := TO_TIME(dropTime * 1000));
IF resetONS.Q OR HMIData.faultActive OR NOT enable THEN
	state := FILLER_STATES.Idle;
	fillerRequestedCycle := FALSE;
	cycleBaggerToActivateFiller.active := FALSE;
	waitingForFiller := FALSE;
	cycleBagRequest := FALSE;
	_baggerCycledAndReady := FALSE;
	_baggerCycleInitiated := FALSE;
	dropTimer.IN := FALSE;
END_IF

IF NOT fillerOK AND enable AND activateFiller THEN
	notReady.Trigger();
END_IF

fillerTrigONS(CLK := fillerTrigger);
IF fillerTrigONS.OSR THEN
	fillerRequestedCycle := TRUE;
END_IF

CASE state OF
	FILLER_STATES.Idle :							IF (activateFiller AND enable) AND NOT HMIData.faultActive THEN
														state := FILLER_STATES.CycleBaggerToActiveFiller;
													END_IF
	
	FILLER_STATES.CycleBaggerToActiveFiller :		
													cycleBaggerToActivateFiller.active := TRUE;
													
													IF _baggerCycledAndReady THEN
														cycleBaggerToActivateFiller.active := FALSE;
														_baggerCycledAndReady := FALSE;
														fillerRequestedCycle := FALSE;
														state := FILLER_STATES.WaitingForFiller;
													END_IF
	
	FILLER_STATES.WaitingForFiller :				// Waiting for filler trigger to initiate cycle
													waitingForFiller := TRUE;
													IF fillerRequestedCycle AND NOT HMIData.baggerInhibited.active THEN
														waitingForFiller := FALSE;	
														fillerRequestedCycle := FALSE;
														state := FILLER_STATES.Dropping;
													END_IF
													
	FILLER_STATES.Dropping :						// Filler is dropping product
													dropTimer.IN := TRUE;
													IF dropTimer.Q THEN
														dropTimer.IN := FALSE;
														cycleBagRequest := TRUE;
														state := FILLER_STATES.BaggerCycling;
													END_IF
	
	FILLER_STATES.BaggerCycling :					// Wait for bag to open 
													IF _baggerCycleInitiated THEN
														_baggerCycleInitiated := FALSE;
														cycleBagRequest := FALSE;
													END_IF
													
													IF _baggerCycledAndReady THEN
														_baggerCycledAndReady := FALSE;
														state := FILLER_STATES.WaitingForFiller;
													END_IF
	
	FILLER_STATES.Fault :
	
END_CASE


METHOD Reset : BOOL
VAR_INPUT
END_VAR

SUPER^.Reset();

METHOD BaggerCycledAndReady : BOOL
VAR_INPUT
END_VAR

_baggerCycledAndReady := TRUE;

PROPERTY Mode : DEVICE_MODES


PROPERTY Ready : BOOL


METHOD BaggerCycleInitiated : BOOL
VAR_INPUT
END_VAR

_baggerCycleInitiated := TRUE;