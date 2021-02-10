(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_BaseComponent IMPLEMENTS IComponentStatus
VAR_INPUT
	enable : BOOL;                    // Enable
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_mode : DEVICE_MODES;            // Auto-SemiAuto-Manual
    _ready : BOOL;                    // Ready to be controlled
	_reset : BOOL;
	enableONS : R_TRIG;
	resetONS : R_TRIG;
	autoModeSelected : BOOL;
    semiAutoModeSelected : BOOL;
    manualModeSelected : BOOL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: BaseComponentFB
//	Description:  Extend this FB for each component as it contains the basic variables and logic that all components must share
//	In all extended FBs you must run the parent logic with SUPER^()
//	Created by: Ben Hess
//	Created Date: Friday, June 1, 2018


enableONS(CLK := enable);
resetONS(CLK := _reset);

autoModeSelected := (_mode = DEVICE_MODES.Auto);
semiAutoModeSelected := (_mode = DEVICE_MODES.SemiAuto);
manualModeSelected := (_mode = DEVICE_MODES.Manual);
IF _reset THEN
	_reset := FALSE;
END_IF