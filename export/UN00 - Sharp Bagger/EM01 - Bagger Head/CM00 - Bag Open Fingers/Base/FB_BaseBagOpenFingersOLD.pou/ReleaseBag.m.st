(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD ReleaseBag
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
_bagCleared := FALSE;
_bagGrabbed := FALSE;
_bagMissed := FALSE;
_grabBagRequest := FALSE;
_releaseBagRequest := TRUE;
_logger.AddLogItem(CONCAT(_prefix,' Release Bag Request'));