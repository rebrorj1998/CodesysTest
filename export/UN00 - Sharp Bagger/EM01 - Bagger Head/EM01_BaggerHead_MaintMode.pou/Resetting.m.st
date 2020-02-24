(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Resetting
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
state := HEAD_STATES.Idle;
sealAndSeparateSubState := SEAL_SEPARATE_STATES.Idle;
releaseAndFeedSubState := RELEASE_FEED_STATES.Idle;
openBagSubState := BAG_OPEN_ASSIST_STATES.Idle;
_resettingDone := TRUE;