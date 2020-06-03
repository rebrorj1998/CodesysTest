(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Close
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
simClose.maxDelay := TO_DINT((actualPassthrough / 22.5) * 1000 + 50);
simClose.minDelay := TO_DINT((actualPassthrough / 22.5) * 1000 + 10);

cylinder.Retract();
jawMotionFaultTime := TO_TIME((actualPassthrough / 22.5) * 1000 + 300);

