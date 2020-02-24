(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Execute
VAR_INPUT
END_VAR

VAR

END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
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

