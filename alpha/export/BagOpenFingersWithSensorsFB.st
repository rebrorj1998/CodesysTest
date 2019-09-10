

FUNCTION_BLOCK BagOpenFingersWithSensorsFB EXTENDS BagOpenFingersFB
VAR_INPUT
	rightFingerBagPresent : BOOL;
	leftFingerBagPreset : BOOL;
END_VAR
VAR_IN_OUT
	bagFailedToGrabBothFingersCount : UDINT; // Both Fingers failed to grab bag
	bagFailedToGrabRightFingerCount : UDINT; // Right Bag Open Finger Failed to Grab Bag
	bagFailedToGrabLeftFingerCount : UDINT; // Left Bag Open Finger Failed to Grab Bag
	successfulBagOpenCount : UDINT;			// Successful Bag Open Count
END_VAR
VAR_OUTPUT
	
END_VAR

SUPER^();

METHOD CheckIfBagGrabbed : BOOL
VAR_INPUT
END_VAR

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
	successfulBagOpenCount := successfulBagOpenCount +1;
	CheckIfBagGrabbed := TRUE;
ELSIF rightFingerBagPresent AND NOT leftFingerBagPreset THEN
	bagFailedToGrabLeftFingerCount := bagFailedToGrabLeftFingerCount +1 ;
ELSIF NOT rightFingerBagPresent AND leftFingerBagPreset THEN
	bagFailedToGrabRightFingerCount := bagFailedToGrabRightFingerCount + 1;
ELSE bagFailedToGrabBothFingersCount := bagFailedToGrabBothFingersCount + 1;
END_IF
{warning restore C0371}