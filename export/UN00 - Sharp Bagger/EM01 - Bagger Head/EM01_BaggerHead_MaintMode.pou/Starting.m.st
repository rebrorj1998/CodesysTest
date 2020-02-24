(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Starting
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF NOT _startingDone THEN
	bagger.pressureBar.Open();
	bagger.bagOpenFingers.ReleaseBag();
	bagger.sealFlatteners.ToBagFeed();
	_startingDone := TRUE;
END_IF