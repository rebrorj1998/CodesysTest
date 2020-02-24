(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Aborting
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF NOT _abortingDone THEN
	bagger.bagOpenFingers.RemovePower();
	bagger.vacuumBagOpen.StopVacuum();
	bagger.pressureBar.RemovePower();
	_abortingDone := TRUE;
END_IF
