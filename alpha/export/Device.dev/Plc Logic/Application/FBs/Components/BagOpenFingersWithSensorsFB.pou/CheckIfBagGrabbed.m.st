(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD CheckIfBagGrabbed : BOOL
VAR_INPUT
	incrementCounters : BOOL; // IF TRUE Incerment bag counters, otherwise just return bag grabbed status
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Returns true if bag grab successful.  Also increments appropriate counters

{warning disable C0371}
// Checking the VAR_IN_OUT reference, leave the current method in case of invalid reference
IF NOT __ISVALIDREF(successfulBagOpenCount) 
	OR NOT __ISVALIDREF(bagFailedToGrabLeftFingerCount)
	OR NOT __ISVALIDREF(bagFailedToGrabRightFingerCount)
	OR NOT __ISVALIDREF(bagFailedToGrabBothFingersCount)
	THEN RETURN;    
END_IF

IF rightFingerBagPresent AND leftFingerBagPreset THEN
	IF incrementCounters THEN
		successfulBagOpenCount := successfulBagOpenCount +1;
	END_IF
	CheckIfBagGrabbed := TRUE;
ELSIF rightFingerBagPresent AND NOT leftFingerBagPreset THEN
	IF incrementCounters THEN
		bagFailedToGrabLeftFingerCount := bagFailedToGrabLeftFingerCount +1 ;
	END_IF
ELSIF NOT rightFingerBagPresent AND leftFingerBagPreset THEN
	IF incrementCounters THEN
		bagFailedToGrabRightFingerCount := bagFailedToGrabRightFingerCount + 1;
	END_IF
ELSE
	IF incrementCounters THEN
		bagFailedToGrabBothFingersCount := bagFailedToGrabBothFingersCount + 1;
	END_IF
END_IF
{warning restore C0371}