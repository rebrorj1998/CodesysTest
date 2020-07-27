(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK MC_Base
VAR_INPUT
	Execute : BOOL; 		// Rising edge: The halt is started 
END_VAR
VAR_OUTPUT
	Done : BOOL;			// Becomes true as soon as the axis has reached velocity zero
	Busy : BOOL;			// TRUE as long as MC_Halt is operating, reset when velocity is zero
	CommandAborted : BOOL;	// Commanded motion was interrupted by any motion FB acting on the same axis
	Error : BOOL;			// Signals that an error has occured
	ErrorID : MC_ERROR;		// Error number
END_VAR
VAR
	ExecuteOSR : Standard.R_TRIG;
	ExecuteOSF : Standard.F_TRIG;
	MC_State : INT;
END_VAR
VAR_IN_OUT
	Axis : Axis_REF;		// Reference to the axis 
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
