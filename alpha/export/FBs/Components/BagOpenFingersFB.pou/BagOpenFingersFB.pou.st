(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
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
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();
releaseOutput := _releaseCommand AND enable;
grabOutput := _grabCommand AND enable;