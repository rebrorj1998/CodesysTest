(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD INTERNAL SetBagOpenState
VAR_INPUT
	newState : BAG_OPEN_ASSIST_STATES;
END_VAR
VAR
	statePrefix : STRING;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
bagOpenSubState := newState;
_logger.AddLogItem(CONCAT('Bag Open State: ',TO_STRING(newState)));