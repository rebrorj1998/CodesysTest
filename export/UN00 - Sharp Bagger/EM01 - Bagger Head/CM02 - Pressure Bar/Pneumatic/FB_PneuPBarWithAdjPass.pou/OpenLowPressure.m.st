(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD OpenLowPressure
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
simOpen.maxDelay := TO_INT((actualPassthrough / 4) * 1000 + 50);
simOpen.minDelay := TO_INT((actualPassthrough / 4) * 1000 + 10);
simOpen.faultDelay := simClose.maxDelay + 300;

ExtendLPIfPossible(cylinder);
faultTime := TO_TIME((actualPassthrough / 4) * 1000 + 300);
