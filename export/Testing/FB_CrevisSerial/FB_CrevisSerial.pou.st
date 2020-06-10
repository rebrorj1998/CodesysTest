(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CrevisSerial EXTENDS CBM.ETrig
VAR_INPUT
	sendData : STRING[60];
	inputs : POINTER TO BYTE;
	outputs : POINTER TO BYTE;
END_VAR
VAR_OUTPUT
	receivedData : STRING[60];
END_VAR
VAR
	serialState : eSerialStates;
	executeONS : FB_ONS;
	readBufferHasData : BOOL;
	readBufferDataSize : BYTE;
	writeBufferDataSize : BYTE;
	readTimeout : Standard.TON := (PT := T#20MS);
	timeToResponse : TIME;
	TA : BOOL;
	TR : BOOL;
	RA : BOOL;
	RR : BOOL;
END_VAR
VAR_IN_OUT

END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
executeONS(CLK := xExecute);
RR := inputs[0].2;
TA := inputs[0].1;


readBufferHasData := inputs[0].4;
readBufferDataSize := inputs[1];
readTimeout(IN := serialState = eSerialStates.getResponse); 

CASE serialState OF
	eSerialStates.Idle :				// Wait for execute
										IF NOT xExecute THEN 
											xDone := FALSE;
										END_IF
										IF executeONS.OSR THEN
											xDone := FALSE;
											OSCAT_BASIC._STRING_TO_BUFFER(STR := sendData,0,ADR(outputs[2]),LEN(sendData));
											outputs[1] := TO_BYTE(Standard.LEN(sendData));
											IF TA THEN
												TR := FALSE;
											ELSE
												TR := TRUE;
											END_IF
											xBusy := TRUE;
											serialState := eSerialStates.getResponse;
										END_IF
	
	eSerialStates.writeOutBuffer :		// 
										
	
	eSerialStates.writingOutBuffer :	// 
										IF TA = TR THEN
											serialState := eSerialStates.getResponse;
										END_IF
	
	eSerialStates.getResponse :			//
										IF readBufferHasData THEN
											IF readTimeout.Q THEN
												timeToResponse := readTimeout.ET;
												IF RR THEN
													RA := FALSE;
												ELSE
													RA := TRUE;
												END_IF
												serialState := eSerialStates.gettingResponse;
											END_IF
											
										ELSIF readTimeout.Q THEN
											receivedData := '';
											xDone := TRUE;
											xBusy := FALSE;
											serialState := eSerialStates.Idle;
										END_IF
	
	eSerialStates.gettingResponse:		IF RA = RR THEN
											receivedData := OSCAT_BASIC.BUFFER_TO_STRING(PT := ADR(inputs[2]),SIZE := 50, 0, readBufferDataSize + 1);
											xDone := TRUE;
											xBusy := FALSE;
											serialState := eSerialStates.Idle;
										END_IF

	
END_CASE

outputs[0].1 := TR;
outputs[0].2 := RA;