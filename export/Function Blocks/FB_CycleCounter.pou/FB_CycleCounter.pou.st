(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CycleCounter
VAR_INPUT
	reset : BOOL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
    count : UDINT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF reset THEN
	THIS^.Clear();
	reset := FALSE;
END_IF