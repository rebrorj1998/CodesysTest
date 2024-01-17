(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'global_init_slot' := '50001'}
VAR_GLOBAL
	initiateCycle : BOOL;  // Initiate Cycle Pushbutton
	ackAllFaults : BOOL; // Acknowledge All Faults from HMI
	counterChange : BOOL; // Acknowledge All Faults from HMI
	makeReady : BOOL;
	homeMachine : BOOL;
	machineHomed : BOOL;
	pressureBarState : STRING;
	activeScreen : DINT;
	jawService : ServiceCommands;
	jawJogOpen : BOOL;
	jawJogClosed : BOOL;
	clampJogClosed: BOOL;
	clampJogOpen: BOOL;
	loadPlateService : ServiceCommands;
	IBDService : ServiceCommands;
	IBDJogOpen : BOOL;
	IBDJogClosed : BOOL;
	IBDMinOpenThreshold : REAL;
	IBDZeroOffset : REAL;
	jogFilmForward : BOOL;
	jogFilmReverse : BOOL;
	cycleSealer : BOOL;
	printHeadService : ServiceCommands;
	startJawCycleTest : BOOL;
	stopJawCycleTest : BOOL;
	clampBypass : BOOL:=FALSE;
	jawCycleTestActive : BOOL;
	teachBagPhotoeye : BOOL;
	teachingBagPhoteye : BOOL;
	factoryHomeJaw : BOOL;
    stopMachine : BOOL;
	inCycle : BOOL;
	resetAverageCycleTime : BOOL;
	bannerMessageIndication : DINT;
	faultActive : BOOL;
	simulateAllIO : BOOL;
	activeFaults : ARRAY[0..GlobalObjects.MAX_FAULTS] OF STRING;
	passthroughActual : REAL;
	currentPackMLState : STRING;
	BPMBagsMade : UDINT;
	BPMActiveTime : STRING;
	BPMBagsPerMinute : REAL;
	BPMReset : BOOL;
	cycleTime : REAL;
	printerReady : BOOL;
	bagDeliveryReady : BOOL;
	loadPlateReady : BOOL;
	jawReady : BOOL;
	bcvReady : BOOL;
	IBDReady : BOOL;
	sendSampleLabels : BOOL;
	clearAllLabels : BOOL;
	printerAndVerifierEnablePB : BOOL;
	printerAndVerifierEnableIndication : BOOL;
	frontJawMotorData : sctOrientalHMIData;
	rearJawMotorData : sctOrientalHMIData;
	loadPlateMotorData : sctOrientalHMIData;
	IBDMotorData : sctOrientalHMIData;
	bagDeliveryMotorData : sctAppliedMotionHMIData;
	barcodeReadGoodIndication : BOOL;
	barcodeReadBadIndication : BOOL;
	barcodeVerifierTrigger : BOOL;
	standbyActive : BOOL;
	resetMotors : BOOL;
	startJawCycleClampTest : BOOL;
	stopJawCycleClampTest : BOOL;
	jawClampDriveFaulted : BOOL;
	jawMotionDriveFaulted : BOOL;
	jawMotionDriveErrorCode : STRING;
	jawResetDrives : BOOL;
	jawClampCycleTestActive : BOOL;
	jawActualPosition : REAL;
	jawActualPositionInSteps : REAL;
	jawTargetPosition : REAL;
	jawTargetPositionInSteps : REAL;
	jawAxisMotorTemperature : REAL;
	filmFeedMotionDriveErrorCode : STRING;
	filmFeedAxisMotorTemperature : REAL;
	faultMessage:STRING;
END_VAR

VAR_GLOBAL PERSISTENT RETAIN
	bagsMade : UDINT;
	batchEnable : BOOL;
	batchSetting : UDINT := 10;
	batchCount : UDINT;
	headCycleCount : UDINT;
	pressureBarOpenDelay : REAL;
	pressureBarCloseDelay : REAL;
	passthroughSetting : REAL := 5.5;
	sealBarDwell : REAL := 0.2;
	sealBarCool : REAL := 0.4;
	bagSkirtLength : REAL := 2;
	bagLength : REAL := 17.62;
	bagWidth : REAL := 11;
	bagThickness : REAL := 2.5;
	bagForwardSpeed : UDINT := 40;
	bagReverseSpeed : UDINT := 8;
	printSpeed : UINT := 6;
	printLength : REAL := 1.25;
	printOffset : REAL := 9.0;
	fillerCountSetting : UDINT;
	fillerCurrentCount : UDINT;
	fillerDropTime : REAL;
	loadPlateDelay : REAL;
	loadPlateDwell : REAL := 0.1;
	IBDInUse : BOOL := TRUE;
	IBDInstalled : BOOL := FALSE;
	jawCloseDelay : REAL := 0.1;
	jawClosePositionSetting : REAL := -0.45;
	lastCycleTime : REAL;
	bagDropClearanceDwell : REAL := 0.5;
	averageCycleTime : REAL;
	currentJobID : INT;
	separateBeforeSeal : BOOL := TRUE;
	partsCounterEnable : BOOL;
	partsCounterCount : UDINT;
	partsCounterSetting : UDINT;
	consecutiveBagsEnable : BOOL;
	consecutiveBagsCount : UDINT;
	consecutiveBagsSetting : UDINT;
	printerInstalled : BOOL := FALSE;
	printerInUse : BOOL := TRUE;
	printerCancelRequest : BOOL;
	barcodeVerifierInstalled : BOOL := FALSE;
	barcodeGoodReadCount : UDINT;
	barcodeBadReadCount : UDINT;
	barcodeBadReadFaultSetting : UDINT := 1;
	barcodeStartPosition : REAL := 4.5;
	barcodeScanDistance : REAL := 0.1;
	barcodeVerifierInUse : BOOL := TRUE;
	loadPlateInstalled : BOOL := FALSE;
	loadPlateLoweredPositionSetting : REAL := 0;
	loadPlateRaisedPositionSetting :  REAL := 1;
	loadPlateInUse : BOOL := TRUE;
	fillerEnable : BOOL;
	autoModeEnable : BOOL;
	autoModeDwell : REAL;
	dryCycleEnable : BOOL;
	standbyTimeSetting : REAL := 5.0;  // Standby timeout in minutes
	jawClampTime : REAL := 1.0;
	jawClampReverseTime : REAL := 1.0;//0.56;
	jawClampInterval : REAL := 2.0;
	jawEnableClamping : BOOL;
	jawCycleTestCycles : DINT;
	jawClampTestCycles : DINT;
	filmFeedTestCycles : DINT;
	jawEnableMotion : BOOL;
	filmEnableMotion : BOOL;

END_VAR

VAR_GLOBAL CONSTANT
	version : STRING := '1.2.0.0';
END_VAR