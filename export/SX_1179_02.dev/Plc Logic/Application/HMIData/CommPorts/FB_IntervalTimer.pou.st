(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_IntervalTimer
VAR_INPUT
	timeNow : BOOL;
END_VAR
VAR_OUTPUT
	intervalTime : TIME;
END_VAR
VAR
	intervalTimer : Standard.TON := (PT := T#1000S);
	intervalTimerONS : FB_ONS;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
intervalTimerONS(CLK := timeNow);
intervalTimer();
IF intervalTimerONS.OSR THEN
	intervalTimer.IN := TRUE;
END_IF

IF intervalTimerONS.OSF THEN
	intervalTime := intervalTimer.ET;
	intervalTimer.IN := FALSE;
END_IF