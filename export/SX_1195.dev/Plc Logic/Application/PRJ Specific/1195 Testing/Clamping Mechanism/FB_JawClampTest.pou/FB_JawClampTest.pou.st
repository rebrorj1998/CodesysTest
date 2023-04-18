(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_JawClampTest EXTENDS CBM.ETrig;
VAR_INPUT
	driveAlarm : BOOL;
	clampMotionInSeconds : REAL; 
	reverseMotionInSeconds : REAL;
	intervalInSeconds : REAL;
END_VAR
VAR_OUTPUT
	oStartMotor : BOOL;
	oForwardMotor : BOOL;
	oResetDrive : BOOL;
	cycleTestActive : BOOL;
	reversing : BOOL;
	Done : BOOL;
END_VAR
VAR
	_startCycle : BOOL;
	_stopCycle : BOOL;
	_state : INT;		

	_clampTimer : Standard.TON;
	_reverseTimer : Standard.TON;
	_intervalTimer : Standard.TON;
	prx_ctu : CTU;
END_VAR
VAR_IN_OUT
	jawClampCycleTestCounter : DINT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

cycleTestActive := _state <> 0;

_clampTimer(PT := TO_TIME(clampMotionInSeconds  * 1000.0), IN := _state = 1);
_reverseTimer(PT := TO_TIME(reverseMotionInSeconds  * 1000.0), IN := _state = 2);
_intervalTimer(PT := TO_TIME(intervalInSeconds  * 1000.0), IN := _state = 3);
reversing := _state=2;
CASE _state OF
	0:  // Idle
		oStartMotor := FALSE;
		oForwardMotor := TRUE;
		IF _startCycle AND NOT driveAlarm THEN
			_startCycle := FALSE;
			_state := 1;
			Done := FALSE;
		END_IF
	1:	// Clamp
		oStartMotor := TRUE;
		IF _clampTimer.Q THEN
			_state := 2;
		END_IF
	2:	// Reverse
		oForwardMotor := FALSE;
		IF _reverseTimer.Q OR iJawNotObstructed THEN
			jawClampCycleTestCounter := jawClampCycleTestCounter + 1;
			_state := 3;
		END_IF
	3:	// Wait for next cycle
		oStartMotor := FALSE;
		oForwardMotor := TRUE;
		_state := 0;
		Done := TRUE;
		
END_CASE

prx_ctu(CU := iJawNotObstructed);

IF driveAlarm OR _stopCycle THEN 
	_stopCycle := FALSE;
	_state := 0;
END_IF