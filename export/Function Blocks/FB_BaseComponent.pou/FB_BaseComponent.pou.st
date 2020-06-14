(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_BaseComponent EXTENDS FB_BaseObject IMPLEMENTS IComponent, IMachineOption
VAR_INPUT
END_VAR
VAR_OUTPUT
	
END_VAR
VAR
    _ready : BOOL;                    // Ready to be controlled
	_reset : BOOL;
	_optionActive : BOOL;
	_optionEnabled : BOOL;
	_optionInstalled : BOOL;
	enableONS : R_TRIG;
	resetONS : R_TRIG;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: BaseComponentFB
//	Description:  Extend this FB for each component as it contains the basic variables and logic that all components must share
//	In all extended FBs must run the parent logic with SUPER^()
//	Created by: Ben Hess
//	Created Date: Friday, June 1, 2018

_optionActive := _optionEnabled AND _optionInstalled;