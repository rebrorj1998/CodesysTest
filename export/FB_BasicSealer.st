

FUNCTION_BLOCK FB_BasicSealer EXTENDS FB_BaseComponent IMPLEMENTS ISealer
VAR_INPUT
	simulateIO : BOOL;
	sealDwell : REFERENCE TO REAL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_beginSealing : BOOL;
	beginSealingONS : FB_ONS;
	sealTimer : TON;
	_sealComplete : BOOL;
	sealActive : BOOL;
	state : INT;
	//beginSealing : FB_SimulatedFeedback(name := CONCAT(_prefix,'Begin Sealing'));
END_VAR

SUPER^();

beginSealingONS(CLK := _beginSealing);
sealTimer();

IF _reset THEN
	sealActive := FALSE;
	_sealComplete := FALSE;
	sealTimer.IN := FALSE;
	state := 0;
END_IF

CASE state OF
	
	0:	IF beginSealingONS.OSR THEN
			_beginSealing := FALSE;
			sealTimer.PT := TO_TIME(sealDwell * 1000.0);
			sealTimer.IN := TRUE;
			sealActive := TRUE;
			state := 1;
		END_IF
	
	1:	IF sealTimer.Q THEN
			sealTimer.IN := FALSE;
			_sealComplete := TRUE;
			sealActive := FALSE;
			state := 0;
		END_IF
	
	2: //
	
	3: //
END_CASE


{attribute 'monitoring' := 'variable'}
PROPERTY SealComplete : BOOL


METHOD BeginSealing

_beginSealing := TRUE;
sealTimer.IN := FALSE;
_sealComplete := FALSE;