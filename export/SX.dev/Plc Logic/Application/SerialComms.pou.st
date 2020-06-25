(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PROGRAM SerialComms
VAR
	serial : FB_CrevisSerial();
	printerLabel : FB_PrinterSerial();
	hIecTask : RTS_IEC_HANDLE;
	firstScanDone  : BOOL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//testASCII();
IF NOT firstScanDone THEN
	hIecTask := IecTaskGetCurrent(0);
	IecTaskDisableWatchdog(hIecTask); // Watchdog disabled
	firstScanDone := TRUE;
END_IF

serial(
	xExecute:= , 
	xDone=> , 
	xBusy=> , 
	xError=> , 
	sendData:= , 
	receivedData=> , 
	inputs:= ADR(serialInputs), 
	outputs:= ADR(serialOutputs));
IF HMIData.sendSampleLabels AND NOT printerLabel.xDone THEN
	printerLabel.xExecute := TRUE;
	printerLabel.sendSampleLabel := TRUE;
	HMIData.sendSampleLabels := FALSE;
END_IF
printerLabel();