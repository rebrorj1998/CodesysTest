(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MonostableMultivibrator EXTENDS FB_BaseComponent
VAR_INPUT
END_VAR
VAR_OUTPUT
	Q : BOOL;   // Output pulse
END_VAR
VAR
	_trigger : BOOL;
	_dwellTimeInMS : UINT := 80; 	// Pulse Dwell in mS 
	_delayTimeInMS : UINT; 			// Delay before Pulse in mS
	_manualOn : BOOL;
	_manualOff : BOOL;
	active : BOOL;
	dwellTimer : Standard.TON;
	delayTimer : Standard.TON;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();

// HPA is on for only as long as its setpoint.

delayTimer(IN := _trigger AND NOT dwellTimer.Q, PT := UINT_TO_TIME(_delayTimeInMS));
dwellTimer(IN := delayTimer.Q AND NOT dwellTimer.Q, PT := UINT_TO_TIME(_dwellTimeInMS));

Q:= delayTimer.Q OR _manualOn;

IF dwellTimer.Q OR _reset THEN
	active := FALSE;
	_trigger := FALSE;
	_manualOn := FALSE;
	_manualOff := FALSE;
END_IF
// Reset trigger right away
// IF _trigger THEN
// 	//active := TRUE;
// 	_trigger := FALSE;
// END_IF