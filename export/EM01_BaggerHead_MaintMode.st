

FUNCTION_BLOCK EM01_BaggerHead_MaintMode EXTENDS FB_PackMLStates
VAR_INPUT
	
END_VAR
VAR_OUTPUT
	state : HEAD_STATES;
    sealAndSeparateSubState : SEAL_SEPARATE_STATES;
    releaseAndFeedSubState : RELEASE_FEED_STATES;
    openBagSubState : BAG_OPEN_ASSIST_STATES;
END_VAR
VAR
	_beginCycleFromInfeeed : BOOL;
	_readyToAcceptProduct : BOOL;
	cycleTimer : TON() := (PT := T#1000S);
	cycleTime : REAL;
	bagOpenRetryCount : UINT;
	bagOpenRetrySetting : UINT := 3;
END_VAR
VAR_IN_OUT
	//modeManager : PACK_ML.UnitModeManager;
	bagger : EM01_BaggerHead;
END_VAR

//	Function Block: EM01_Bagger_Automode
//	Description: This is an implementation of a bagger in Auto Mode (normal operation) using the PackML standard.
//				 Each method is a PackML state.
//	Created by: Ben Hess
//	Created Date: Tuesday, March 26, 2019

METHOD Stopping

_stoppingDone := TRUE;

METHOD Stopped

_clearingDone := FALSE;

METHOD Resetting

state := HEAD_STATES.Idle;
sealAndSeparateSubState := SEAL_SEPARATE_STATES.Idle;
releaseAndFeedSubState := RELEASE_FEED_STATES.Idle;
openBagSubState := BAG_OPEN_ASSIST_STATES.Idle;
_resettingDone := TRUE;

METHOD Idle

_resettingDone := FALSE;

METHOD Starting

IF NOT _startingDone THEN
	bagger.pressureBar.Open();
	bagger.bagOpenFingers.ReleaseBag();
	bagger.sealFlatteners.ToBagFeed();
	_startingDone := TRUE;
END_IF

METHOD Executing

//	Method: EM01_Bagger_MaintMode.Executing()
//	Description: Executing is the state in which the machine is ready to accept "service commands".  
//				 
//	Created by: Ben Hess
//	Created Date: Tuesday, March 27, 2019
_startingDone := FALSE;


METHOD Aborting

IF NOT _abortingDone THEN
	bagger.bagOpenFingers.RemovePower();
	bagger.vacuumBagOpen.StopVacuum();
	bagger.pressureBar.RemovePower();
	_abortingDone := TRUE;
END_IF


METHOD Aborted

_abortingDone := FALSE;

METHOD Clearing

_clearingDone := TRUE;

METHOD Held

_holdingDone := FALSE;

METHOD Holding

_holdingDone := TRUE;

METHOD UnHolding

_unholdingDone := TRUE;

METHOD Complete

_completingDone := FALSE;

METHOD Completing

_completingDone := TRUE;

FUNCTION_BLOCK EM01_BaggerHead_MaintMode EXTENDS FB_PackMLStates
VAR_INPUT
	
END_VAR
VAR_OUTPUT
	state : HEAD_STATES;
    sealAndSeparateSubState : SEAL_SEPARATE_STATES;
    releaseAndFeedSubState : RELEASE_FEED_STATES;
    openBagSubState : BAG_OPEN_ASSIST_STATES;
END_VAR
VAR
	_beginCycleFromInfeeed : BOOL;
	_readyToAcceptProduct : BOOL;
	cycleTimer : TON() := (PT := T#1000S);
	cycleTime : REAL;
	bagOpenRetryCount : UINT;
	bagOpenRetrySetting : UINT := 3;
END_VAR
VAR_IN_OUT
	//modeManager : PACK_ML.UnitModeManager;
	bagger : EM01_BaggerHead;
END_VAR

//	Function Block: EM01_Bagger_Automode
//	Description: This is an implementation of a bagger in Auto Mode (normal operation) using the PackML standard.
//				 Each method is a PackML state.
//	Created by: Ben Hess
//	Created Date: Tuesday, March 26, 2019

METHOD Stopping

_stoppingDone := TRUE;

METHOD Stopped

_clearingDone := FALSE;

METHOD Resetting

state := HEAD_STATES.Idle;
sealAndSeparateSubState := SEAL_SEPARATE_STATES.Idle;
releaseAndFeedSubState := RELEASE_FEED_STATES.Idle;
openBagSubState := BAG_OPEN_ASSIST_STATES.Idle;
_resettingDone := TRUE;

METHOD Idle

_resettingDone := FALSE;

METHOD Starting

IF NOT _startingDone THEN
	bagger.pressureBar.Open();
	bagger.bagOpenFingers.ReleaseBag();
	bagger.sealFlatteners.ToBagFeed();
	_startingDone := TRUE;
END_IF

METHOD Executing

//	Method: EM01_Bagger_MaintMode.Executing()
//	Description: Executing is the state in which the machine is ready to accept "service commands".  
//				 
//	Created by: Ben Hess
//	Created Date: Tuesday, March 27, 2019
_startingDone := FALSE;


METHOD Aborting

IF NOT _abortingDone THEN
	bagger.bagOpenFingers.RemovePower();
	bagger.vacuumBagOpen.StopVacuum();
	bagger.pressureBar.RemovePower();
	_abortingDone := TRUE;
END_IF


METHOD Aborted

_abortingDone := FALSE;

METHOD Clearing

_clearingDone := TRUE;

METHOD Held

_holdingDone := FALSE;

METHOD Holding

_holdingDone := TRUE;

METHOD UnHolding

_unholdingDone := TRUE;

METHOD Complete

_completingDone := FALSE;

METHOD Completing

_completingDone := TRUE;