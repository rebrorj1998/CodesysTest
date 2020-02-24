(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE ClearStatus
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
feedAtPrintSpeed.in := FALSE;
feedBagOut.in := FALSE;
feedToPrintOffset.in := FALSE;
reverseToSeparate.in := FALSE;
THIS^.Execute();