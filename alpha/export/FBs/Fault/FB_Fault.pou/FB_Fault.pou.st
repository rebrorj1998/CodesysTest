(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_Fault IMPLEMENTS IFault, ILoggable, IExecuteAutomatically
VAR_INPUT
	ackCommand : BOOL;
	faultTrigger : BOOL;
END_VAR
VAR_OUTPUT
	acknowledged : BOOL;
	active : BOOL;
END_VAR
VAR
	_acked : BOOL;
	_active : BOOL;
	_logger : IMachineLogger;
	_faultTriggerONS : FB_ONS;
	_ackCommandONS : FB_ONS;
	_activeONS : FB_ONS;
	_instanceName : STRING;
END_VAR
VAR_IN_OUT
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
