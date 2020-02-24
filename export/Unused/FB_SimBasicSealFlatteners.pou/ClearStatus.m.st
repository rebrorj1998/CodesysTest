(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE ClearStatus
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
moveToBagFeed.in := FALSE;
moveToBagHolding.in := FALSE;
moveToClearance.in := FALSE;
moveToSeal.in := FALSE;
moveToIn.in := FALSE;
THIS^.Execute();