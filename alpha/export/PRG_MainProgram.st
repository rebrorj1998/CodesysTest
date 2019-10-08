

PROGRAM PRG_MainProgram
VAR
    incrementSolenoidCounter1 : R_TRIG();
    incrementSolenoidCounter2 : R_TRIG();
    incrementSolenoidFailedCounter2 : R_TRIG();
    GripperCycleCount : DINT; //Gripper Cycle Counter
    runPrinterPB : BOOL;
    cycleTimeMax : TIME;
    cycleTimeMaxDINT : DINT;
    ctfb : OSCAT_BASIC.CYCLE_TIME();
    profileThis :BOOL;
    solenoidState1 : SOLENOID_TEST_STATES;
    solenoidState2 : SOLENOID_TEST_STATES;
    getTimeTilPMMI : TimeLeftFB();
	displayPassthroughChangeDistance : REAL;
	displayPassthroughChangeDistance2 : REAL;
	checkSolenoid2ExtendTimer : TON := (PT := T#100MS);
	checkedSolenoid2Status : BOOL;
	firstScanDone : BOOL;
	printDeltaTimer : TON := (PT := T#5S);
	lastPrinterDelta : TIME;
	endPrintOSF : Standard.R_TRIG;
	CSVWriter : FB_WriteToFile() := (xFilePath := 'C:/printerDelta.csv');
	stringToLog : STRING;
	testWrite : BOOL;
	hmiLight : FB_HMILight;
	versionInfo : VERSION;
END_VAR
//    Program: Main (PLC_PRG)
//    Description: This program serves as a base for the MOAB Prototype
//    Created by: Ben Hess
//    Created Date: January 16th, 2018

endPrintOSF(CLK := printerEndOfPrint);
printDeltaTimer(IN := oPrinterStartPrint);
IF endPrintOSF.Q OR testWrite THEN
	lastPrinterDelta := printDeltaTimer.ET;
	Globals.lastPrinterDelta := printDeltaTimer.ET;
	stringToLog :=  CONCAT(TO_STRING(PRG_Bagger.currentDateAndTime.dtCurrent),',');
	stringToLog := Standard.CONCAT(stringToLog,TO_STRING(printDeltaTimer.ET));
	//CSVWriter.xText_Write := stringToLog;
	//CSVWriter.xWrite := TRUE;
	testWrite := FALSE;
END_IF
// 
// CSVWriter(
// 	xFilePath:= , 
// 	xText_Write:= , 
// 	xAppend_OverWrite:= TRUE, 
// 	xAppend_Pos:= , 
// 	xWrite:= , 
// 	xRead:= , 
// 	xLine_No_To_Read:= , 
// 	xText_Read=> , 
// 	xDone=> );
// IF CSVWriter.xDone THEN
// 	CSVWriter.xWrite := FALSE;
// END_IF

ctfb(ct_max => cycleTimeMax);
cycleTimeMaxDINT := TIME_TO_DINT(cycleTimeMax);
profileThis := TIME_TO_DINT(ctfb.ct_last) >= 25;
// Run other programs
//PRG_PneumaticHead();
PRG_Bagger();
Faults();
versionInfo := GetVersion();
HMIData.version := Standard.CONCAT(TO_STRING(versionInfo.uiMajor),'.');
	BPLog.AppendToString(ADR(HMIData.version), CONCAT(TO_STRING(versionInfo.uiMinor),'.'));
	BPLog.AppendToString(ADR(HMIData.version), CONCAT(TO_STRING(versionInfo.uiServicePack),'.'));
	BPLog.AppendToString(ADR(HMIData.version), TO_STRING(versionInfo.uiPatch));
	BPLog.AppendToString(ADR(HMIData.version), TO_STRING(GetTextProperty("VersionPostfix")));
IF NOT firstScanDone THEN
	GlobalObjects.CollectionOfLoggable.RegisterAll(internalLogger := Globals.SystemLog);
	GlobalObjects.CollectionOfInitialzable.InitializeAll();
	firstScanDone := TRUE;
	// After first scan turn off flag set by StartDone system event
	Globals.firstScan := FALSE;	
END_IF

// Start executing objects that implement IExecuteAutomatically 
IF firstScanDone THEN
	GlobalObjects.CollectionOfExecutable.ExecuteAll();
	Globals.SystemLog();
END_IF




IF HMIData.ackAllFaults THEN
	GlobalObjects.CollectionOfActiveFaults.AckAll();
	HMIData.ackAllFaults := FALSE;
END_IF

getTimeTilPMMI(targetDate := DT#2018-10-14-8:0:0);


//First scan flag is set by task handler and reset in main routine here
IF Globals.firstScan THEN
    Globals.firstScan := FALSE;
END_IF

displayPassthroughChangeDistance := (UDINT_TO_REAL(Globals.passthroughChangeDistance) / 10);
displayPassthroughChangeDistance2 := (UDINT_TO_REAL(Globals.passthroughChangeDistance2) / 10.0);