(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_Fault IMPLEMENTS IFault, ILoggable, IExecuteAutomatically
VAR_INPUT
	faultTrigger : BOOL;
	
END_VAR
VAR_OUTPUT
	active : BOOL;
END_VAR
VAR
	_ack : BOOL;
	_acked : BOOL;
	_passive : BOOL;
	_exitConveyorOverride : BOOL;
	_externalExitConveyorOverride : BOOL;
	_logger : IMachineLogger;
	_ackOSR : Standard.R_TRIG;
	_activeONS : FB_ONS;
	_faultTriggerONS : FB_ONS;
	_passiveOSF : Standard.F_TRIG;
	_passiveTimeout : Standard.TON;
	_timeoutDwell : REAL;
	_triggerRequiredToMoveToActiveFaults : PASSIVE_FAULT_TRIGGERS;
	_instanceName : STRING;
	_isOEEExempt : BOOL;
	_isPassiveExempt : BOOL;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
