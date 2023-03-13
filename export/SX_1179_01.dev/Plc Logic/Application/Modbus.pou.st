(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PROGRAM Modbus
VAR
	firstScanDone : BOOL;
	hIecTask : RTS_IEC_HANDLE;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF NOT firstScanDone THEN
	hIecTask := IecTaskGetCurrent(0);
	IecTaskDisableWatchdog(hIecTask); // Watchdog disabled
	firstScanDone := TRUE;
END_IF