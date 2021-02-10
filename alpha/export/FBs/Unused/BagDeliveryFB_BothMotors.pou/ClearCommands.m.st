(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE ClearCommands
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
_amFeedBagOut := FALSE;
_amReverseBag := FALSE;
_amPrinterDone := FALSE;
_amPrinterReady := FALSE;
_amWaitForPrinter := FALSE;
_amStartPrint := FALSE;
//_amFeedToEye := FALSE;