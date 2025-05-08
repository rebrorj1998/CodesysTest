(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// This function block describes an unit mode with all possible machine states, actions and the current state. 
// The transition between unit modes is handled by the UnitModeMangager. 
{attribute 'hide_all_locals'} 
FUNCTION_BLOCK UnitMode IMPLEMENTS IUnitMode
VAR_INPUT
	sName : STRING; // Name of the unit mode
	dwSupportedStates : DWORD := 2#11111111111111111; // Supported states
	dwAllowsLeavingFromStates : DWORD := PackMLState.Stopped OR PackMLState.Aborted; // Leaving state conditions
	dwAllowsEnteringIntoStates: DWORD := PackMLState.Stopped OR PackMLState.Aborted; // Entering state conditions
	eInitialState: PackMLState; // Initialization state
	xActive : BOOL; // True if this unit mode is active
END_VAR
VAR_OUTPUT
END_VAR
VAR
	eState:PackMLState:=PackMLState.Invalid;
	bInit: BOOL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF NOT bInit THEN
	bInit:=TRUE;
	eState := eInitialState;
END_IF