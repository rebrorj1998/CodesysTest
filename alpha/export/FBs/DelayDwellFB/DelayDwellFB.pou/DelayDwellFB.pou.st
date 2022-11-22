(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK DelayDwellFB EXTENDS FB_BaseComponent
VAR_INPUT
END_VAR
VAR_OUTPUT
	Q : BOOL;   // Output pulse
END_VAR
VAR
	_trigger : BOOL;
	_dwellTimeInMS : DINT := 80; 	// Pulse Dwell in mS 
	_delayTimeInMS : DINT; 			// Delay before Pulse in mS
	_manualOn : BOOL;
	_manualOff : BOOL;
	active : BOOL;
	dwellTimer : Standard.TON;
	delayTimer : Standard.TON;
	state : DELAY_DWELL_STATES;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: DelayDwellFB
//    Description: On Trigger(), starts a delay then sets the Q output for a dwell time.  Each addition Trigger() resets the dwell timer.
//    Created by: Ben Hess
//    Created Date: February 20th, 2020

// Setup timers for reading offset and scanning distance
delayTimer(PT := UDINT_TO_TIME(_delayTimeInMS));
// If negative dwell time, run forever
IF _dwellTimeInMS < 0 THEN
	dwellTimer(PT := T#0MS);
ELSE
	dwellTimer(PT := UDINT_TO_TIME(_dwellTimeInMS));
END_IF

// Manual On/Off
IF _manualOff THEN
	THIS^.Reset();
	state := DELAY_DWELL_STATES.Idle;
ELSIF _manualOn THEN
	THIS^.Reset();
	Q := TRUE;
	state := DELAY_DWELL_STATES.Idle;
END_IF

CASE state OF
	DELAY_DWELL_STATES.Idle:  			//
										dwellTimer.IN := FALSE;
										delayTimer.IN := FALSE;
										
										IF _trigger THEN
											IF _delayTimeInMS <> 0 THEN
												state := DELAY_DWELL_STATES.Delay;
											ELSE
												state := DELAY_DWELL_STATES.Dwell;
											END_IF
											_trigger := FALSE;
										END_IF
	
	DELAY_DWELL_STATES.Delay: 			//
										delayTimer.IN := TRUE;
										IF delayTimer.Q THEN
											delayTimer.IN := FALSE;
											state := DELAY_DWELL_STATES.Dwell;
										END_IF
	
	DELAY_DWELL_STATES.Dwell: 			//
										Q := TRUE;
										IF _dwellTimeInMS >= 0 THEN
											dwellTimer.IN := TRUE;
											IF dwellTimer.Q THEN
												dwellTimer.IN := FALSE;
												Q := FALSE;
												state := DELAY_DWELL_STATES.Idle;
											END_IF
										END_IF
										IF _trigger THEN
											_trigger := FALSE;
											state := DELAY_DWELL_STATES.ResettingDwell;
										END_IF
										
	DELAY_DWELL_STATES.ResettingDwell: 	//
										dwellTimer.IN := FALSE;
										state := DELAY_DWELL_STATES.Dwell;
END_CASE

SUPER^();
