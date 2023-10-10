(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_StateRateTracking
VAR CONSTANT
	NbMaxArrayDepth: INT := 30;
	stopTime: TIME := T#30S;
END_VAR

VAR_INPUT
	stateName : string;
	cntUp: BOOL;
	state:INT;
	trackingEnable: BOOL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	cntUpONS: R_TRIG;
	stateTimer:TON;
	laststate: INT;
	count_index :INT :=0;
	clr:BOOL:=FALSE;
	speedTracking : ARRAY[0..NbMaxArrayDepth] OF stateRateKeyPair;
	speedTracking_mt : ARRAY[0..20] OF time := [21(T#0MS)]; 
	state_index : INT:=0;
	index: INT;
	
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
cntUpONS(CLK:= cntUp);
IF trackingEnable THEN
		IF cntUpONS.Q THEN
			count_index := count_index +1;
		END_IF
	FOR index :=0 TO NbMaxArrayDepth DO
		IF clr THEN
				count_index := 0;
				speedTracking[index].stateID:=-1;
				speedTracking[index].cycleArray:= speedTracking_mt;
		ELSIF  speedTracking[index].stateID = state THEN
			state_index := index;
			EXIT;
		ELSIF speedTracking[index].stateID = -1 THEN
			state_index := index;
			speedTracking[index].stateID := state;
			speedTracking[index].stateName := stateName;
			EXIT;
		END_IF
	END_FOR
	clr:=FALSE;
	stateTimer(PT:=T#10000S);
	IF state  = laststate THEN
		stateTimer.IN := TRUE;
	ELSIF state  <> laststate THEN
		stateTimer.IN := FALSE;
		laststate:=state;
	END_IF
IF stopTime> stateTimer.ET AND stateTimer.ET >T#0MS THEN
	speedTracking[state_index].cycleArray[count_index] := stateTimer.ET;
END_IF
	
	IF count_index >=20 THEN
		count_index :=0;
	END_IF
ELSE
	count_index := 0;
END_IF
