(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD FeedAtPrintSpeed
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
ClearStatus();
feedAtPrintSpeed.maxDelay := TO_DINT(((printLength / TO_REAL(printSpeed)) * 1000) + 50.0);  
feedAtPrintSpeed.minDelay := TO_DINT(((printLength / TO_REAL(printSpeed)) * 1000) + 10.0);  
feedAtPrintSpeed.in := TRUE;