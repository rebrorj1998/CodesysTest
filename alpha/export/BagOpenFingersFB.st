

FUNCTION_BLOCK BagOpenFingersFB EXTENDS BaseComponentFB
VAR_INPUT

END_VAR
VAR_IN_OUT

END_VAR
VAR_OUTPUT
    releaseOutput : BOOL;
	grabOutput : BOOL;
END_VAR
VAR
    _releaseCommand : BOOL;
    _grabCommand : BOOL;
END_VAR

SUPER^();
releaseOutput := _releaseCommand;
grabOutput := _grabCommand;

METHOD Release
VAR_INPUT
END_VAR

_releaseCommand := TRUE;
_grabCommand := FALSE;

METHOD Grab
VAR_INPUT
END_VAR

_releaseCommand := FALSE;
_grabCommand := TRUE;
HMIData.bagOpenFingerCycles.Increment();