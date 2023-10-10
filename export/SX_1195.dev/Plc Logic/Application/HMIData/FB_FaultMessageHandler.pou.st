(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_FaultMessageHandler
VAR_INPUT
	faultActive:BOOL  := FALSE;
	faultCount :UINT := 0;
	messageDelay : TIME := T#1500MS;
	faultList : ARRAY[0..GlobalObjects.MAX_FAULTS] OF STRING;;
END_VAR
VAR_OUTPUT
	faultMessagestr: STRING;
END_VAR
VAR
	fCount: INT;
	displayTimer : TON;
	timer_ons: FB_ONS;
	Test:BOOL;

END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
displayTimer(PT:=messageDelay);
timer_ons(CLK:= displayTimer.Q);
IF faultActive THEN 
	faultMessagestr := faultList[fCount];
	IF timer_ons.OSR THEN
		fCount := fCount +1;
	END_IF
	IF test AND fCount < GlobalObjects.MAX_FAULTS THEN
		IF (faultList[fCount] = '') THEN
			fCount:= 0;
		END_IF
	ELSIF test THEN
		fCount := 0;
	END_IF
	IF NOT displayTimer.Q THEN 
		displayTimer.IN := TRUE;
	ELSE
		displayTimer.IN:= FALSE;
		Test:=NOT Test;
	END_IF
ELSE
	faultMessagestr:= '';
END_IF