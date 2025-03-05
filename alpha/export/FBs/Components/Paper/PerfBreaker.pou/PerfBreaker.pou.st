(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK PerfBreaker EXTENDS FB_ThreePositionCylinder
VAR_INPUT
	upStatusDelay : TIME := T#250MS;
	downStatusDelay : TIME := T#250ms;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	upStatusTimer : TON;
	downStatusTimer : TON;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

//Retract = up, extend = down
upStatusTimer(IN := retractOutput, PT := upStatusDelay);
downStatusTimer(IN := extendOutput, PT := downStatusDelay);
extendedStatus := downStatusTimer.Q;
retractedStatus := upStatusTimer.Q;