(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Checks if the state allows entering.
{attribute 'hide'} 
METHOD AllowsEntering : BOOL
VAR_INPUT
	e: State;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF (e AND dwAllowsEnteringIntoStates) > 0 THEN
	AllowsEntering := TRUE;
END_IF