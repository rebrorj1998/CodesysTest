(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD GrabBag
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
_bagCleared := FALSE;
_bagGrabbed := FALSE;
_bagMissed := FALSE;
_releaseBagRequest := FALSE;
_grabBagRequest := TRUE;
_logger.AddLogItem(CONCAT(_prefix,' Grab Bag Request'));