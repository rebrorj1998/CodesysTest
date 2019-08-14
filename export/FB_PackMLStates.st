

FUNCTION_BLOCK FB_PackMLStates EXTENDS FB_BaseObject IMPLEMENTS IPackMLStates, IAllObjects
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_abortingDone : BOOL;
	_clearingDone : BOOL;
	_completingDone : BOOL;
	_holdingDone : BOOL;
	_resettingDone : BOOL;
	_startingDone : BOOL;
	_unholdingDone : BOOL;
	_stoppingDone : BOOL;
END_VAR



PROPERTY AbortingDone : BOOL


PROPERTY ClearingDone : BOOL


PROPERTY CompletingDone : BOOL


PROPERTY HoldingDone : BOOL


PROPERTY ResettingDone : BOOL


PROPERTY StartingDone : BOOL


PROPERTY UnholdingDone : BOOL


METHOD Aborting

_abortingDone := TRUE;

METHOD Clearing

_clearingDone := TRUE;

METHOD Stopped

_clearingDone := FALSE;

METHOD Idle

_resettingDone := FALSE;

METHOD Starting

_startingDone := TRUE;

METHOD Executing



METHOD Aborted

_abortingDone := FALSE;

METHOD Stopping

_stoppingDone := TRUE;

METHOD Resetting

_resettingDone := TRUE;

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

PROPERTY StoppingDone : BOOL