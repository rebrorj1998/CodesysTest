(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_TestSerial
// This example shows how to communicate via the library SysCom.
VAR
	bOpenCom: BOOL := TRUE;
	hCom: RTS_IEC_HANDLE := RTS_INVALID_HANDLE;
	Result: RTS_IEC_RESULT;
	csComSettings: COM_Settings;
	bWriteCom: BOOL := TRUE;
	dwWritten: UDINT;
	dwOffset: UDINT;
	str : STRING := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890$R$N';
	abyWriteData: array[0..4095] of BYTE;
	i: INT;
	bReadCom: BOOL := TRUE;
	dwRead: UDINT;
	strRead: STRING;
	dwWrittenLog : ARRAY[0..49] OF DWORD;
	dwZeroWrittenCount : DWORD;
	iCurWrittenLog : INT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF bOpenCom THEN
	bOpenCom := FALSE;
	// Prepare test data
	FOR i:=0 TO 4095 DO
		abyWriteData[i] := str[i MOD 64];
	END_FOR
	// Open COM port 1
	hCom := SysComOpen(sPort:= SYS_COMPORT1 , pResult:= ADR(Result));
	IF hCom <> RTS_INVALID_HANDLE THEN
		// Configure the connection
		csComSettings.byParity := SYS_NOPARITY;
		csComSettings.byStopBits := SYS_ONESTOPBIT;
		csComSettings.sPort := SYS_COMPORT1;
		csComSettings.ulBaudrate := SYS_BR_9600;
		csComSettings.ulBufferSize := 0;
		csComSettings.ulTimeout := 10;
		Result := SysComSetSettings(hCom:= hCom, pSettings:= ADR(csComSettings) , pSettingsEx:= 0);
	END_IF
END_IF

IF hCom <> RTS_INVALID_HANDLE AND bWriteCom THEN
	// Write data
	dwWritten := SysComWrite(hCom:= hCom,	pbyBuffer:= ADR(abyWriteData)+dwOffset,	ulSize:= SIZEOF(abyWriteData)-dwOffset,	ulTimeout:= 100,	pResult:= ADR(Result) );
	IF dwWritten = 0 THEN
		dwZeroWrittenCount := dwZeroWrittenCount + 1;
	ELSE
		dwWrittenLog[iCurWrittenLog] := dwWritten;
		iCurWrittenLog := iCurWrittenLog + 1;
		IF iCurWrittenLog > 49 THEN
			iCurWrittenLog := 0;
		END_IF
	END_IF
	dwOffset := dwOffset + dwWritten;
	IF dwOffset >= SIZEOF(abyWriteData) THEN
		bWriteCom := FALSE;
		dwOffset := 0;
	END_IF
END_IF

IF hCom <> RTS_INVALID_HANDLE AND bReadCom THEN
	// Read data
	dwRead := SysComRead(hCom:= hCom,	pbyBuffer:= ADR(strRead),	ulSize:= SIZEOF(strRead),	ulTimeout:= 100,	pResult:= ADR(Result));
	IF dwRead > 0 THEN
		SysComWrite(hCom:= hCom,	pbyBuffer:= ADR(strRead),	ulSize:= dwRead,	ulTimeout:= 10, pResult:= ADR(Result));
	END_IF
END_IF