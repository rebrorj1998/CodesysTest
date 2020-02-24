(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_PhysicalAnalogInput EXTENDS FB_BaseObject IMPLEMENTS IExecuteAutomatically, ILoggable
VAR_INPUT
	in : REFERENCE TO WORD;		// Raw Analog Input
	enableLogging : BOOL;		// Enable logging
	logDeadband : INT;			// Deadband to log changes
END_VAR
VAR_OUTPUT
	RawValue : WORD;
END_VAR
VAR
	logged : BOOL;
	loggedValue : INT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
