(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
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
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
