(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_BaseObject IMPLEMENTS IAllObjects, ILoggable
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_instanceName : STRING;			// Instance Name
	_prefix : STRING;
	_logger : IMachineLogger;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
