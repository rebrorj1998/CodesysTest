(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_BagOpenFingers EXTENDS FB_BaseComponent
VAR_INPUT
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