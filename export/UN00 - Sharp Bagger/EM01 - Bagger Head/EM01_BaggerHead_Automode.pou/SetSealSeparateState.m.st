(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD INTERNAL SetSealSeparateState
VAR_INPUT
	newState : SEAL_SEPARATE_STATES;
END_VAR
VAR
	statePrefix : STRING;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
sealAndSeparateSubState := newState;
statePrefix := CONCAT(TO_STRING(state), ' - ');
_logger.AddLogItem(CONCAT(statePrefix,TO_STRING(newState)));