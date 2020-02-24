(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD FeedToPrintOffset
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
ClearStatus();
feedToPrintOffset.maxDelay := TO_DINT(((printOffset / TO_REAL(feedSpeed)) * 1000) + 50.0);  
feedToPrintOffset.minDelay := TO_DINT(((printOffset / TO_REAL(feedSpeed)) * 1000) + 20.0);  
feedToPrintOffset.in := TRUE;