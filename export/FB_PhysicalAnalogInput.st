

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



METHOD Execute
VAR_INPUT
END_VAR

VAR

END_VAR
IF __ISVALIDREF(in) THEN
	RawValue := in;
END_IF

IF TO_INT(RawValue) < (loggedValue - logDeadband) OR TO_INT(RawValue) > (loggedValue + logDeadband) THEN
	logged := FALSE;
END_IF

IF NOT logged AND enableLogging THEN
    _logger.AddLogItem(CONCAT(_prefix, TO_STRING(RawValue)));
	loggedValue := TO_INT(RawValue);
	logged := TRUE;
END_IF



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



METHOD Execute
VAR_INPUT
END_VAR

VAR

END_VAR
IF __ISVALIDREF(in) THEN
	RawValue := in;
END_IF

IF TO_INT(RawValue) < (loggedValue - logDeadband) OR TO_INT(RawValue) > (loggedValue + logDeadband) THEN
	logged := FALSE;
END_IF

IF NOT logged AND enableLogging THEN
    _logger.AddLogItem(CONCAT(_prefix, TO_STRING(RawValue)));
	loggedValue := TO_INT(RawValue);
	logged := TRUE;
END_IF

