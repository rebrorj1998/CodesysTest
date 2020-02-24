(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_PhysicalDigitalOutput EXTENDS FB_BaseObject IMPLEMENTS ILoggable, ISimulateable
VAR_INPUT
	refOutput : REFERENCE TO BOOL; //  Reference to physical output
	
END_VAR
VAR_OUTPUT
	Q : BOOL;		// Logical inidcation of output
END_VAR
VAR
	outputONS : FB_ONS;
	_simulate : BOOL;	// Simulate output - do not trigger actual physical output
END_VAR
VAR_IN_OUT
	
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
