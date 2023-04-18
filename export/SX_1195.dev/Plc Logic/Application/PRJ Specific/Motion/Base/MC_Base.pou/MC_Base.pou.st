(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK MC_Base
VAR_INPUT
	execute : BOOL; 		// Rising edge: The halt is started 
END_VAR
VAR_OUTPUT
	errorID : eMCError;		// Error number
END_VAR
VAR
	_executeOSR : Standard.R_TRIG;
	_executeOSF : Standard.F_TRIG;
	_engineState : eMCEngineState;
	_moveState : eMCMoveState;
END_VAR
VAR_IN_OUT
	axis : Axis_REF;		// Reference to the axis 
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
