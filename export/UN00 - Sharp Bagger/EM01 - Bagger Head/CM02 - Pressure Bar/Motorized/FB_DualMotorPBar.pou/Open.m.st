(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Open
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
simOpen.maxDelay := TO_INT((actualPassthrough / 22.5) * 1000 + 50);
simOpen.minDelay := TO_INT((actualPassthrough / 22.5) * 1000 + 10);


cylinder.Extend();
jawMotionFaultTime := TO_TIME((actualPassthrough / 22.5) * 1000 + 300);
