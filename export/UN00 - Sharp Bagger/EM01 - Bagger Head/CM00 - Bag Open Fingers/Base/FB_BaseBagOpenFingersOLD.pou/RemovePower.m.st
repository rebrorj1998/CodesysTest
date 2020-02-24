(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD RemovePower
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
_bagCleared := FALSE;
_bagGrabbed := FALSE;
_bagMissed := FALSE;
_grabBagRequest := FALSE;
_releaseBagRequest := FALSE;
_logger.AddLogItem(CONCAT(_prefix,' Remove Power Request'));