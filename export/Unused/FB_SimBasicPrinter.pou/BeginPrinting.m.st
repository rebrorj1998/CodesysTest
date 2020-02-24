(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD BeginPrinting
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
ClearStatus();
beginPrinting.maxDelay := TO_DINT(((printLength / TO_REAL(printSpeed)) * 1000) + 50.0);  
beginPrinting.minDelay := TO_DINT(((printLength / TO_REAL(printSpeed)) * 1000) + 10.0);  
beginPrinting.in := TRUE;