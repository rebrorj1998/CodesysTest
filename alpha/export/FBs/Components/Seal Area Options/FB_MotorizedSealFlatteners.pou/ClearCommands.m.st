(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE ClearCommands
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Clear all commands from auto mode
_amMoveOut := FALSE;
_amMoveClearance := FALSE;
_amMoveInToBagHolding := FALSE;
_amMoveIn := FALSE;
_amMoveHandLoad := FALSE;
_amMoveToFeedToSeal := FALSE;