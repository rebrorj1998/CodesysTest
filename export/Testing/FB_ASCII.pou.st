(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_ASCII
VAR_INPUT
	xExecute : BOOL;
	xWaitForResponse : BOOL;
	xInit : BOOL;
	strSendData : STRING;
END_VAR
	
VAR_OUTPUT
	xDone : BOOL;
	xBusy : BOOL;
	xError : BOOL;
	xInitDone : BOOL;
	xInitFail : BOOL;
	strDataRead : STRING;
END_VAR
VAR
	comOpen : COM.Open;
	writeData : COM.Write;
	readData : COM.Read;
	aParamsB115200 : ARRAY [1..7] OF COM.PARAMETER := [
    (udiParameterId := COM.CAA_Parameter_Constants.udiPort,             udiValue := 2),
    (udiParameterId := COM.CAA_Parameter_Constants.udiBaudrate,         udiValue := 115200),
    (udiParameterId := COM.CAA_Parameter_Constants.udiParity,           udiValue := COM.PARITY.NONE),
    (udiParameterId := COM.CAA_Parameter_Constants.udiStopBits,         udiValue := COM.STOPBIT.ONESTOPBIT),
    (udiParameterId := COM.CAA_Parameter_Constants.udiTimeout,          udiValue := 0),
    (udiParameterId := COM.CAA_Parameter_Constants.udiByteSize,         udiValue := 8),
    (udiParameterId := COM.CAA_Parameter_Constants.udiBinary,           udiValue := 1)];
	comState : INT; 
	stringSize : DINT;
END_VAR
VAR_IN_OUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
writeData();
readData();
stringSize := LEN(strSendData);
CASE comState OF
	0:	// Open com port
		IF xInit AND NOT xInitDone THEN
			comOpen(usiListLength := SIZEOF(aParamsB115200)/SIZEOF(COM.PARAMETER), pParameterList := ADR(aParamsB115200));
			comOpen.xExecute := TRUE;
		END_IF
		
		IF comOpen.xDone THEN
			xInitDone := TRUE;
			comOpen.xExecute := FALSE;
			writeData.hCom := comOpen.hCom;
			writeData.pBuffer := ADR(strSendData);
			readData.hCom := comOpen.hCom;
			readData.pBuffer := ADR(strDataRead);
			readData.szBuffer := 10;
			comState := 1;
		ELSIF comOpen.xError THEN
			xInitFail := TRUE;
			comOpen.xExecute := FALSE;
		END_IF
		
	1: // COM Port open - write if you like
		IF xExecute THEN
			xBusy := TRUE;
			xDone := FALSE;
			xError  := FALSE;
			
			writeData.szSize := TO_UINT(LEN(strSendData));
			writeData.xExecute := TRUE;
			comState := 10;		
		END_IF
		
	10: // Wait for write to complete
		IF writeData.xDone OR writeData.xError THEN
			IF writeData.xDone THEN
				
				IF xWaitForResponse THEN 
					comState := 11;
				ELSE
					xBusy := FALSE;
					xDone := TRUE;
					comState := 1;
				END_IF
			ELSIF writeData.xError THEN
				xBusy := FALSE;
				xError := TRUE;
			END_IF
		END_IF
		
	11:	// Get response
		readData.xExecute := TRUE;
		IF readData.xDone THEN
			xDone := TRUE;
			xBusy := FALSE;		
			comState := 1;
		ELSIF readData.xError THEN
			xBusy := FALSE;
			xError := TRUE;
		END_IF
	
END_CASE

