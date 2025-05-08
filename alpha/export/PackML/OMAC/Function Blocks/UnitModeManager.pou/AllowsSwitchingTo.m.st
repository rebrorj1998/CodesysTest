(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Checks if the current state allows switching the current unit mode.
{attribute 'hide'} 
METHOD PRIVATE AllowsSwitchingTo : BOOL
VAR_INPUT
	usi: USINT; // Unit mode to switch
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF usi=usiActualUM THEN
	AllowsSwitchingTo := TRUE;
ELSE
	AllowsSwitchingTo := apum[usiActualUM].AllowsLeaving AND apum[usi].AllowsEntering(ActiveUnitMode.CurrentState);
END_IF