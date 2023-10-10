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
	//variables for the state timer
	stateTimer:TON;
	laststate: INT;
	count_index :INT :=0;
	clr:BOOL:=FALSE;
	speedTracking : ARRAY[0..20] OF ARRAY[0..20] OF TIME;
	speedTracking_mt : ARRAY[0..20] OF ARRAY[0..20] OF TIME:=[21([21(T#0S)])]; 
	state_index : INT:=0;
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
//code to add timer to track duration in states
state_index := state;
stateTimer(PT:=T#10000S);
IF clr THEN
	speedTracking:=speedTracking_mt;
	clr:=FALSE;
END_IF
IF state  = laststate THEN
	stateTimer.IN := TRUE;
ELSIF state  <> laststate THEN
	stateTimer.IN := FALSE;
	IF state =0 THEN
		count_index := count_index +1;
	END_IF
	laststate:=state;
END_IF
speedTracking[state_index][count_index] := stateTimer.ET;

IF count_index >=20 THEN
	count_index :=0;
END_IF
//End modded code
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
