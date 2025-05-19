(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'reflection'}
FUNCTION_BLOCK FB_StateRateTracking
VAR CONSTANT
	NbMaxArrayDepth: INT := 70;
END_VAR

VAR_INPUT
	stopTime: TIME := T#30S;
	stateName : string;
	cntUp: BOOL;
	state:INT;
	trackingEnable: BOOL;
	clr:BOOL:=FALSE;
	rtc:ULINT:=0;
	uniqueID:STRING(3);
END_VAR
VAR_OUTPUT
END_VAR
VAR
{attribute 'instance-path'}
{attribute 'noinit'}
 str: STRING;
END_VAR
VAR
	fileDateString: ARRAY[0..6] OF STRING;
	Date_and_time_format: RTS_SYSTIMEDATE;
	set: INT;
	pOffset: INT;
	maxSamples: INT := 3;
	dataready: BOOL;
	subindex: INT;
	writing: BOOL;
	last_subindex: INT;
	length: DINT;
	cntUpONS: R_TRIG;
	stateTimer:TON;
	laststate: INT;
	count_index :INT :=0;
	speedTracking : ARRAY[0..NbMaxArrayDepth] OF stateRateKeyPair;
	speedTracking_mt : ARRAY[0..20] OF TIME := [21(T#0MS)]; 
	speedTrackingts_mt : ARRAY[0..20] OF ULINT := [21(0)]; 
	state_index : INT:=0;
	index: INT;
	nsTimeStamp : ULINT;
	name: STRING;
	nameloc: INT;
	pre: STRING(255);
	fname: STRING(255);
	dataPoint: INT :=0;
	writeString: STRING(5000);
	tempString: ARRAY [0..10] OF STRING(255);
	outputCSV: FB_fileWrite;
	cr: STRING(2) := '$R$N';
	unlatch_ons : FB_ONS;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
cntUpONS(CLK:= cntUp);
nameloc:=FIND(STR1:=str,'.ts_');
pre:= RIGHT(str,(LEN(str)-nameloc));
name := left(pre,len(pre));
SysTimeRtcConvertUtcToDate(dwTimestampUtc:=TO_DWORD(rtc/1000) ,pdate:= Date_and_time_Format);
fileDateString[0]:= CONCAT('_',TO_STRING(Date_and_time_format.wYear));
fileDateString[1]:= CONCAT('_',TO_STRING(Date_and_time_format.wMonth));
fileDateString[2]:= CONCAT('_',TO_STRING(Date_and_time_format.wDay));
fileDateString[3]:= CONCAT(fileDateString[0],fileDateString[1]);
fileDateString[4]:= CONCAT(fileDateString[3],fileDateString[2]);
fileDateString[5]:= CONCAT(name,fileDateString[4]);
fname:= CONCAT(fileDateString[5], '.csv');
outputCSV(filename:=fname);

//Date_and_time_format := ULINT_TO_DT(rtc);

IF trackingEnable THEN
		IF cntUpONS.Q THEN
			count_index := count_index +1;
		END_IF
	
	FOR index :=0 TO NbMaxArrayDepth DO
		IF clr THEN
				count_index := 0;
				speedTracking[index].stateID:=-1;
				speedTracking[index].cycleArray:= speedTracking_mt;
				speedTracking[index].t_stampArray := speedTrackingts_mt;
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
		nsTimeStamp := rtc;
		laststate:=state;
	END_IF
IF stopTime> stateTimer.ET AND stateTimer.ET >T#0MS THEN
	speedTracking[state_index].cycleArray[count_index] := stateTimer.ET;
	speedTracking[state_index].t_stampArray[count_index] := nsTimeStamp;
	speedTracking[state_index].uidArray[count_index] := uniqueID;
	
END_IF
unlatch_ons(CLK:=count_index = 16);
IF unlatch_ons.osr OR writing THEN
		writing := TRUE;
		outputCSV.exec:=FALSE;
		IF speedTracking[subindex].stateID > -1 THEN
		IF NOT outputCSV.busy THEN
			length:=0;
			FOR dataPoint:=1 TO maxSamples DO			
				tempString[0] := CONCAT(TO_STRING(speedTracking[subindex].t_stampArray[dataPoint+(pOffset*maxSamples)]),',');	
				tempString[1] := concat(TO_STRING(TO_DINT(speedTracking[subindex].cycleArray[dataPoint+(pOffset*maxSamples)])),',');
				tempString[2] := CONCAT(speedTracking[subindex].stateName,',');
				tempString[3] := CONCAT(tempString[0],tempString[1]);
				tempString[4] := CONCAT(tempString[2],TO_STRING(subindex));
				tempString[5] := CONCAT(tempString[3],tempString[4]);
				tempString[6] := CONCAT(tempString[5],',');
				tempString[7] := CONCAT(tempString[6],speedTracking[subindex].uidArray[dataPoint+(pOffset*maxSamples)]);
				tempString[8] := CONCAT(tempString[7],cr);
				IF LEN(writestring)+LEN(tempString[8])<255 THEN
					writeString := CONCAT(writestring,tempString[8]);
				END_IF
			END_FOR
				outputCSV(exec:= TRUE,writestr:= writeString,strLength:=len(writeString));
			END_IF
			IF outputCSV.writeSuccess AND outputCSV.exec AND NOT outputCSV.busy THEN
				IF pOffset >=4 THEN
					subindex := subindex+1;
					pOffset := 0;

				ELSE
					pOffset := pOffset + 1;
				END_IF
				writeString := '';
				outputCSV.exec:=FALSE;
			END_IF
 		ELSE 
			writing := FALSE;
			subindex := 0;
			last_subindex :=-1;
		END_IF
END_IF
IF outputCSV.fileWriteTimeout THEN
	writing := FALSE;
	subindex := 0;
	outputCSV.exec:=FALSE;
	writeString := '';
END_IF
IF count_index >=20 THEN

	
	count_index :=0;
END_IF

ELSE
	count_index:= 0;
END_IF