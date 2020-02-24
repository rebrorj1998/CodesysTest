(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD INTERNAL SetReleaseFeedState
VAR_INPUT
	newState : RELEASE_FEED_STATES;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
releaseAndFeedSubState := newState;
_logger.AddLogItem(CONCAT('Release/Feed State: ',TO_STRING(newState)));