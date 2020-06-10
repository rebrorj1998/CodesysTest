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
END_VAR

VAR_GLOBAL PERSISTENT RETAIN
	printerAndVerifierEnablePB : BOOL;
	printerAndVerifierEnableIndication : BOOL;
	BPMBagsMade : DINT;
	BPMActiveTime : REAL;
	BPMBagsPerMinute : REAL;
	BPMReset : BOOL;
	version : STRING := '0.2A';
	bagsMade : DINT;
	batchEnable : BOOL;
	batchSetting : UDINT := 10;
	batchCount : UDINT;
	headCycleCount : UDINT;
	pressureBarOpenDelay : REAL;
	pressureBarCloseDelay : REAL;
	passthroughSetting : REAL := 5.5;
	sealBarDwell : REAL := 0.0;
	sealBarCool : REAL := 0.0;
	bagSkirtLength : REAL := 1.35;
	bagLength : REAL := 23.5;
	bagWidth : REAL := 17.5;
	bagThickness : REAL := 2.5;
	bagForwardSpeed : UDINT := 20;
	bagReverseSpeed : UDINT := 3;
	printSpeed : UDINT := 6;
	printLength : REAL := 8.0;
	printOffset : REAL := 2.0;
	fillerCountSetting : UDINT;
	fillerCurrentCount : UDINT;
	fillerDropTime : REAL;
	loadPlateDelay : REAL;
	loadPlateDwell : REAL := 2.5;
	IBDInUse : BOOL;
	IBDInstalled : BOOL;
	IBDOpenMotionProfile : sctMotionProfile := (velo := 13.0, accel := 150.0, decel := 150.0, current := 100.0);
	IBDCloseMotionProfile : sctMotionProfile := (velo := 10.0, accel := 10.0, decel := 10.0, current := 50.0);
	IBDZeroOffset : REAL := 2.0;
	jawCloseDelay : REAL := 0.2;
	jawClosePositionSetting : REAL := -0.2;
	jawOpenMotionProfile : sctMotionProfile := (velo := 10.0, accel := 10.0, decel := 10.0, current := 100.0);
	jawCloseMotionProfile : sctMotionProfile := (velo := 10.0, accel := 10.0, decel := 10.0, current := 100.0);
	jawCycleTestCycles : DINT;
	jawCycleTestActive : BOOL;
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
	printerInstalled : BOOL;
	printerInUse : BOOL;
	printerCancelRequest : BOOL;
	barcodeVerifierInstalled : BOOL;
	barcodeGoodReadCount : UDINT;
	barcodeBadReadCount : UDINT;
	barcodeBadReadFaultSetting : UDINT;
	barcodeStartPosition : REAL;
	barcodeScanDistance : REAL := 1.0;
	barcodeVerifierInUse : BOOL;
	barcodeReadGoodIndication : BOOL;
	barcodeReadBadIndication : BOOL;
	loadPlateInstalled : BOOL;
	loadPlateLoweredPositionSetting : REAL := 0;
	loadPlateRaisedPositionSetting :  REAL := 1;
	loadPlateInUse : BOOL;
	loadPlateRaiseProfile : sctMotionProfile := (velo := 1.0, accel := 10.0, decel := 10.0, current := 100.0);
	loadPlateLowerProfile : sctMotionProfile := (velo := 5.0, accel := 100.0, decel := 100.0, current := 100.0);
	fillerEnable : BOOL;
	autoModeEnable : BOOL;
	autoModeDwell : REAL := 0.75;
END_VAR