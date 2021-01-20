(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CylinderLeak EXTENDS FB_PredictiveMaint
VAR_INPUT
	iExtended : BOOL;
	iRetracted : BOOL;
	maximumStrokeTime : REAL;
END_VAR
VAR_OUTPUT
	strokeTime : REAL;
END_VAR
VAR
	strokeTimer : TON := (PT := T#1H);
	extendedONS : R_TRIG;
	retractedONS : R_TRIG;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
extendedONS(CLK := iExtended);
retractedONS(CLK := iRetracted);

IF extendedONS.Q OR retractedONS.Q THEN
	strokeTime := TO_REAL(strokeTimer.ET) / 1000;
END_IF

strokeTimer(IN := NOT iExtended AND NOT iRetracted);