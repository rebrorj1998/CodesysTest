(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_BasicSealer EXTENDS FB_BaseComponent IMPLEMENTS ISealer
VAR_INPUT
	simulateIO : BOOL;
	sealDwell : REFERENCE TO REAL;
	sealCool : REFERENCE TO REAL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_beginSealing : BOOL;
	beginSealingONS : FB_ONS;
	sealTimer : TON;
	coolTimer : Standard.TON;
	_sealComplete : BOOL;
	sealActive : BOOL;
	state : INT;
	//beginSealing : FB_SimulatedFeedback(name := CONCAT(_prefix,'Begin Sealing'));
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();

beginSealingONS(CLK := _beginSealing);
sealTimer();
coolTimer();
IF _reset THEN
	sealActive := FALSE;
	_sealComplete := FALSE;
	sealTimer.IN := FALSE;
	coolTimer.IN := FALSE;
	_reset := FALSE;
	state := 0;
END_IF
_ready := state = 0;
CASE state OF
	
	0:	IF beginSealingONS.OSR THEN
			
			_beginSealing := FALSE;
			_sealComplete := FALSE;
			sealTimer.PT := TO_TIME(sealDwell * 1000.0);
			coolTimer.PT := TO_TIME(sealCool * 1000.0);
			sealTimer.IN := TRUE;
			IF sealDwell <> 0 THEN
				sealActive := TRUE;
			END_IF
			state := 1;
		END_IF
	
	1:	// Wait for dwell then go to cool
		IF sealTimer.Q THEN
			sealTimer.IN := FALSE;
			sealActive := FALSE;
			IF sealCool <> 0 THEN
				coolTimer.IN := TRUE;
				state := 2;
			ELSE
				_sealComplete := TRUE;
				state := 0;
			END_IF
			
		END_IF
	
	2: // Wait for cool then complete
		IF coolTimer.Q THEN
			coolTimer.IN := FALSE;
			_sealComplete := TRUE;
			state := 0;
		END_IF	
	
	3: //
END_CASE
