(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_BagOpenFingersWithSensors EXTENDS FB_BagOpenFingers
VAR_INPUT
	rightFingerBagPresent : BOOL;
	leftFingerBagPreset : BOOL;
END_VAR
VAR_IN_OUT
	bagFailedToGrabBothFingersCount : UDINT; // Both Fingers failed to grab bag
	bagFailedToGrabRightFingerCount : UDINT; // Right Bag Open Finger Failed to Grab Bag
	bagFailedToGrabLeftFingerCount : UDINT;  // Left Bag Open Finger Failed to Grab Bag
	successfulBagOpenCount : UDINT;			 // Successful Bag Open Count
END_VAR
VAR_OUTPUT	
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();