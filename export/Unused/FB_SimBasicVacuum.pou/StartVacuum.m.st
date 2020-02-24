(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD StartVacuum
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
ClearStatus();
startVac.maxDelay := TO_INT(vacGrabDwell * 1000.0 + 10.0);  
startVac.minDelay := TO_INT(vacGrabDwell * 1000.0 - 10.0);   
startVac.in := TRUE;