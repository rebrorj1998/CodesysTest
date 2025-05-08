(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD TriggerAfter
VAR_INPUT
	triggerRequired : PASSIVE_FAULT_TRIGGERS;
	exitConveyorOverride : BOOL;
	externalExitConveyorOverride : BOOL;
	timeoutDwell : REAL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

// If already set high, return
IF _passive THEN
	RETURN;
END_IF
_passive := TRUE;

//
_exitConveyorOverride := exitConveyorOverride;
_externalExitConveyorOverride := externalExitConveyorOverride;
_triggerRequiredToMoveToActiveFaults := triggerRequired;
_timeoutDwell := timeoutDwell;

//
GlobalObjects.CollectionOfPassiveFaults.AddObject(THIS^);
IF _logger <> 0 THEN
	_logger.AddLogItem(CONCAT(InstanceName,  ' Passive'));
END_IF
