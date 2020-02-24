(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD BeginDischarge
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
ClearStatus();
beginDischarge.maxDelay := TO_INT(loadPlateDwell * 1000.0 + 600.0);  
beginDischarge.minDelay := TO_INT(loadPlateDwell * 1000.0 + 400.0);   
beginDischarge.in := TRUE;