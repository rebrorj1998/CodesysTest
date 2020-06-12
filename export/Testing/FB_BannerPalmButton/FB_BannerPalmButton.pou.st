(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_BannerPalmButton
VAR_INPUT
	baggerReady : BOOL;
	baggerFaulted : BOOL;
	baggerInCycle : BOOL;
END_VAR
VAR_OUTPUT
	palmState0Output : BOOL;
	palmState1Output : BOOL;
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
palmState0Output := FALSE;
palmState1Output := FALSE;
IF baggerReady THEN
	palmState0Output := TRUE;
	palmState1Output := FALSE;
END_IF
IF baggerInCycle THEN
	palmState0Output := TRUE;
	palmState1Output := TRUE;
END_IF
IF baggerFaulted THEN
	palmState0Output := FALSE;
	palmState1Output := TRUE;
END_IF