(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Switch to an other unit mode and check the permission.
// Returns true if switching is allowed, returns false if switching is forbidden.
METHOD SwitchUnitMode : BOOL
VAR_INPUT
	sNewModeName: STRING; // Name of the unit mode to switch
END_VAR
VAR
	pnew: POINTER TO UnitMode;
	usi: USINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
usi := FindMode(sNewModeName);
SwitchUnitMode := FALSE;
IF usi>gc_usiMaxModes THEN
	RETURN;
END_IF

IF usi=usiActualUM THEN
	SwitchUnitMode := TRUE;
	RETURN;
END_IF

IF apum[usiActualUM].AllowsLeaving AND apum[usi].AllowsEntering(ActiveUnitMode.CurrentState) THEN
	apum[usi].Enter(ActiveUnitMode.CurrentState);
	apum[usiActualUM].Active := FALSE;
	apum[usi].Active := TRUE;
	usiActualUM := usi;
	SwitchUnitMode := TRUE;
END_IF