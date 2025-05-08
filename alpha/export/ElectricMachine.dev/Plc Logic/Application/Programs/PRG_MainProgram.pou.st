(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PROGRAM PRG_MainProgram
VAR
    cycleTimeMax : TIME;
    cycleTimeMaxDINT : DINT;
    ctfb : OSCAT_BASIC.CYCLE_TIME();
	firstScanDone : BOOL;
	versionInfo : VERSION;
	saveParametersTimer : Standard.TON := (PT := T#10M);
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Program: Main (PLC_PRG)
//    Description: This program serves as the entry point for the rest of the program
//    Created by: Ben Hess
//    Created Date: January 16th, 2018

saveParametersTimer(IN := NOT saveParametersTimer.Q AND HMIData.bagsMade.count <> 0);
IF saveParametersTimer.Q THEN
	saveParametersTimer.IN := FALSE;
	SaveValuesPeriodic();
END_IF


ctfb(ct_max => cycleTimeMax);
cycleTimeMaxDINT := TIME_TO_DINT(cycleTimeMax);
// Run other programs
PRG_Bagger();

versionInfo := GetVersion();
HMIData.version := Standard.CONCAT(TO_STRING(versionInfo.uiMajor),'.');
	BPLog.AppendToString(ADR(HMIData.version), CONCAT(TO_STRING(versionInfo.uiMinor),'.'));
	BPLog.AppendToString(ADR(HMIData.version), CONCAT(TO_STRING(versionInfo.uiServicePack),'.'));
	BPLog.AppendToString(ADR(HMIData.version), TO_STRING(versionInfo.uiPatch));
	BPLog.AppendToString(ADR(HMIData.version), TO_STRING(GetTextProperty("VersionPostfix")));
	
//Set maximum passthrough based on model selection
CASE HMIdata.baggerModelSelection OF
	ModelSelection.Pro18_1174,
	ModelSelection.Pro18_1183:
		 Globals.maximumPassthough := Globals.MAXIMUM_PASSTHROUGH_PRO18;
			  
	ModelSelection.Pro24_1182,
	ModelSelection.Pro24_1196:
		 Globals.maximumPassthough := Globals.MAXIMUM_PASSTHROUGH_PRO24;		  
END_CASE

// Perform functions on first scan
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


//First scan flag is set by task handler and reset in main routine here
IF Globals.firstScan THEN
    Globals.firstScan := FALSE;
END_IF