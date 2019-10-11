

PROGRAM PLC_PRG
VAR
	firstScan : BOOL; //First Scan Bit
	firstScanDone : BOOL; //First Scan Bit
	SystemLog : FB_InternalLogger;
END_VAR

SystemLog();

IF NOT firstScanDone THEN
	GlobalObjects.CollectionOfInitialzable.InitializeAll();
	GlobalObjects.CollectionOfLoggable.RegisterAll(internalLogger := SystemLog);
	GlobalObjects.CollectionOfFaults.FaultUpdateForHMI();
	firstScanDone := TRUE;
END_IF