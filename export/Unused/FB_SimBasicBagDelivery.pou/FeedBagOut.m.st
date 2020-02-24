(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD FeedBagOut
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
ClearStatus();
feedBagOut.maxDelay := TO_DINT(((bagLength / TO_REAL(feedSpeed)) * 1000) + 50.0);  
feedBagOut.minDelay := TO_DINT(((bagLength / TO_REAL(feedSpeed)) * 1000) + 10.0);  
feedBagOut.in := TRUE;