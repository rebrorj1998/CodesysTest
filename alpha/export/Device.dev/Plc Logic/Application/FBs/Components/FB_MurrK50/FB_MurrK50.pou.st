(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MurrK50
VAR_INPUT
	baggerReady : BOOL;
	baggerFaulted : BOOL;
	baggerInCycle : BOOL;
END_VAR
VAR_OUTPUT
	IOLinkStateOutput : BYTE;
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IOLinkStateOutput := 0;
IF baggerReady THEN
	IOLinkStateOutput := 1;
END_IF
IF baggerInCycle THEN
	IOLinkStateOutput := 2;
END_IF
IF baggerFaulted THEN
	IOLinkStateOutput := 3;
END_IF