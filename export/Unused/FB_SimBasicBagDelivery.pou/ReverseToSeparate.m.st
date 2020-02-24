(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD ReverseToSeparate
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
ClearStatus();
reverseToSeparate.maxDelay := TO_DINT(((reverseLength / TO_REAL(reverseSpeed)) * 1000) + 50.0);  
reverseToSeparate.minDelay := TO_DINT(((reverseLength / TO_REAL(reverseSpeed)) * 1000) + 10.0);  
reverseToSeparate.in := TRUE;