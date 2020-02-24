(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_Fault EXTENDS FB_BaseObject IMPLEMENTS IFault, ILoggable, IExecuteAutomatically
VAR_INPUT
	ackCommand : BOOL;
	faultTrigger : BOOL;
END_VAR
VAR_OUTPUT
	acknowledged : BOOL;
	Active : BOOL;
END_VAR
VAR
	_active : BOOL;
	_acked : BOOL;
	_ackCommand : BOOL;
	ackCommandOSR : R_TRIG;
	faultTriggerONS : FB_ONS;
	activeONS : FB_ONS;
END_VAR
VAR_IN_OUT
	
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
