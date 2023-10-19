(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'global_init_slot' := '50001'}
VAR_GLOBAL
	initiateCycle : BOOL;  // Initiate Cycle Pushbutton
	ackAllFaults : BOOL; // Acknowledge All Faults from HMI
	makeReady : BOOL;
	homeMachine : BOOL;
	machineHomed : BOOL;
	pressureBarState : STRING;
	activeScreen : DINT;
	jawService : ServiceCommands;
	jawJogOpen : BOOL;
	jawjobClosed : BOOL;
	loadPlateService : ServiceCommands;
	IBDService : ServiceCommands;
	IBDJogOpen : BOOL;
	IBDJogClosed : BOOL;
	jogFilmForward : BOOL;
	jogFilmReverse : BOOL;
	cycleSealer : BOOL;
	printHeadService : ServiceCommands;
	startJawCycleTest : BOOL;
	stopJawCycleTest : BOOL;
	jawCycleTestCycles : DINT;
	jawCycleTestActive : BOOL;
	teachBagPhotoeye : BOOL;
	teachingBagPhoteye : BOOL;
	factoryHomeJaw : BOOL;
    stopMachine : BOOL;
	inCycle : BOOL;
	resetAverageCycleTime : BOOL;
	profaceInterface : ARRAY[0..20] OF INT;
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
	printSpeed : UDINT := 6;
	printLength : REAL := 1.25;
	printOffset : REAL := 9.0;
	fillerCountSetting : UDINT;
	fillerCurrentCount : UDINT;
	fillerDropTime : REAL;
	loadPlateDelay : REAL;
	loadPlateDwell : REAL := 0.1;
	IBDInUse : BOOL := FALSE;
	IBDInstalled : BOOL := FALSE;
	IBDOpenMotionProfile : sctMotionProfile := (velo := 9.0, accel := 30.0, decel := 50.0, current := 100.0);
	IBDCloseMotionProfile : sctMotionProfile := (velo := 15.0, accel := 10.0, decel := 10.0, current := 50.0);
	IBDZeroOffset : REAL := 2.0;
	jawCloseDelay : REAL := 0.1;
	jawClosePositionSetting : REAL := -0.45;
	jawOpenMotionProfile : sctMotionProfile := (velo := 14.0, accel := 300.0, decel := 300.0, current := 100.0);
	jawCloseMotionProfile : sctMotionProfile := (velo := 14.0, accel := 10.0, decel := 10.0, current := 100.0);
	jawZeroOffset : REAL := 2.0;
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
	printerInUse : BOOL := FALSE;
	printerCancelRequest : BOOL;
	barcodeVerifierInstalled : BOOL := FALSE;
	barcodeGoodReadCount : UDINT;
	barcodeBadReadCount : UDINT;
	barcodeBadReadFaultSetting : UDINT := 1;
	barcodeStartPosition : REAL := 4.5;
	barcodeScanDistance : REAL := 0.1;
	barcodeVerifierInUse : BOOL := FALSE;
	loadPlateInstalled : BOOL := FALSE;
	loadPlateLoweredPositionSetting : REAL := 0;
	loadPlateRaisedPositionSetting :  REAL := 1;
	loadPlateInUse : BOOL := FALSE;
	loadPlateRaiseProfile : sctMotionProfile := (velo := 3.0, accel := 100.0, decel := 10.0, current := 100.0);
	loadPlateLowerProfile : sctMotionProfile := (velo := 5.0, accel := 100.0, decel := 100.0, current := 100.0);
	fillerEnable : BOOL;
	autoModeEnable : BOOL;
	autoModeDwell : REAL;
	dryCycleEnable : BOOL;
END_VAR

VAR_GLOBAL CONSTANT
	version : STRING := '1.0.7.4';
END_VAR