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
	_active : BOOL;
	_acked : BOOL;
	_ackCommand : BOOL;
	_logger : IMachineLogger;
	ackCommandOSR : R_TRIG;
	faultTriggerONS : FB_ONS;
	activeONS : FB_ONS;
	_instanceName : STRING;
END_VAR
VAR_IN_OUT
	
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
