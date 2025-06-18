(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// All HMI data is presented through this GVL
{attribute 'qualified_only'}
{attribute 'global_init_slot' := '50001'}
VAR_GLOBAL // PERSISTENT RETAIN
	initiateCycle : BOOL;  // Initiate Cycle Pushbutton
	ackAllFaults : BOOL; // Acknowledge All Faults from HMI
	makeReady : BOOL;
	jobLoaded : BOOL;
    stopMachine : BOOL;
	version : STRING;
	inCycle : BOOL;
	batchEnable : BOOL;
	autoEnable : BOOL;
	autoModeDwell : REAL;
	batchSetting : UDINT := 10;
	batchCount : UDINT;
	batchReset : BOOL;
	headCycleCount : UDINT;
	pressureBarOpenDelay : REAL;
	pressureBarCloseDelay : REAL;
	pressureBarPositionBuffer: DINT := 50;
	passthroughSetting : REAL := 5.0;
	passthroughOffset : REAL;
	passthroughPosition : REAL;
	lpaDwell : REAL;
	hpaDwell : REAL;
	sealBarDwell : REAL;
	sealBarTemperatureSetting : UDINT;
	sealBarTemperature : UDINT;
	sealFlattenersPosition : REAL;
	bagSkirtLength : REAL := 1.35;
	bagLength : REAL := 23.5;
	bagWidth : REAL := 17.5;
	bagThickness : REAL := 2.5;
	bagTensionSetting : REAL := 0.6;  // Bag takeup tension setting in amps
	bagDropTime : REAL;
	bagForwardSpeed : UDINT := 55;
	bagReverseSpeed : UDINT := 3;
	bagEdgePhotoeyeCovered : BOOL;
	printSpeed : UDINT := 6;
	printLength : REAL := 8.0;
	printOffset : REAL := 2.0;
	printOutOfCycleEnable : BOOL;
	printerCycleSelection : PrinterCycleSelection;
	fillerCountSetting : UDINT;
	fillerCurrentCount : UDINT;
	fillerDropTime : REAL;
	fillerEnable : BOOL; 
	loadPlateInUse : BOOL;
	loadPlateDelay : REAL;
	loadPlateDwell : REAL;
	rearLoadPlateShakerDelay : REAL;
	rearLoadPlateShakerDwell : REAL;
	rearLoadPlateShakerOnDuration : REAL;
	rearLoadPlateShakerOffDuration : REAL;
	rearloadPlateShakerStart : SHAKER_START_SELECTION;
	frontLoadPlateShakerDelay : REAL;
	frontLoadPlateShakerDwell : REAL;
	frontLoadPlateShakerOnDuration : REAL;
	frontLoadPlateShakerOffDuration : REAL;
	frontloadPlateShakerStart : SHAKER_START_SELECTION;
	loadShelfDelay : REAL := 0.1;
	loadShelfDwell : REAL := 1.5;
	loadShelfShakerDelay : REAL;
	loadShelfShakerDwell : REAL;
	loadShelfShakerOnDuration : REAL;
	loadShelfShakerOffDuration : REAL;
	loadShelfShakerStart : SHAKER_START_SELECTION;
	exitConveyorDwell : REAL;
	vacuumDwell : REAL := 0.25;
	IBDDeflateDwellTime  : REAL := 0.75;
	IBDClosePosition : REAL := 0;
	IBDPackageEjectAssistDelayTime : REAL;
	IBDPackageEjectAssistDwellTime : REAL := 0.8;
	funnelInUse : BOOL;								// Funnel Enable/Disable
	funnelOpenDelay : REAL := 0.25;					// Funnel Open Delay after pressure bar open
	funnelOpeningTime : REAL := 0.5;				// For funnel w/o sensors only : Time required to consider funnel open after command to open
	funnelClosingTime : REAL := 0.5;				// For funnel w/o sensors only : Time required to consider funnel closed after command to close
	stagingFunnelOpenDelay : REAL := 0.25;					// Funnel Open Delay after pressure bar open
	stagingFunnelOpeningTime : REAL := 0.5;				// For funnel w/o sensors only : Time required to consider funnel open after command to open
	stagingFunnelClosingTime : REAL := 0.5;				// For funnel w/o sensors only : Time required to consider funnel closed after command to close
	externalExitConveyorDwell : REAL;
	barcodeGoodReadCount : UDINT;
	barcodeBadReadCount : UDINT;
	barcodeBadReadFaultSetting : UDINT;
	barcodeStartPosition : REAL;
	barcodeScanDistance : REAL := 1.0;
	barcodeVerifierInUse : BOOL;
	barcodeLastReadString : STRING[100];
	barcodeScanDuration : REAL := 2.5;                // Used when 2D barcode is selected
	lastCycleTime : REAL;
	averageCycleTime : REAL;
	resetAverageCycleTime : BOOL;
	bagOpenRetrySetting : INT := 3;
	bagOpenRetryCount : INT;
	bagOpenFeedNewBagSetting : INT := 1;
	bagOpenFeedNewBagCount : INT;
	bagOpenEnable : BOOL := TRUE;
	currentJobID : INT;
	separateBeforeSeal : BOOL;
	activateDemoMode : BOOL;
	printerInUse : BOOL;
	printerInstalled : BOOL;
	lpaDuringBagFeedEnable : BOOL := TRUE;
	lpaBagEjectAssistEnable : BOOL := TRUE;
	infeedConveyorRunningMode : BOOL;  			//0 = Indexing, 1 = Continuous
	infeedConveyorCountingMode : BOOL;			// 0 = Flight, 1 = Parts
	infeedIndexDwellTimer : REAL := 0.25;
	infeedFlightCountTarget : DINT := 5;
	infeedFlightCountActual : DINT;
	infeedPartsCountTarget : DINT := 10;
	infeedPartsCountActual : DINT;
	infeedEmptyPartsSetting : DINT := 10;
	infeedEmptyPartsActual : DINT;
	printAndApplyTriggerDelayWithLOTAR : REAL := 0;
	printAndApplyTriggerDelayWithoutLOTAR : REAL := 0;
	printAndApplyConveyorDwell : REAL := 5.0;
	printAndApplyProductToPhotoeyeTime : REAL := 4.0;
	printAndApplyWaitForLabelTimeout : REAL := 15.0;
	enableDryCycle : BOOL;          // Enable dry cycle
	baggerNeedsClearing : BOOL;
	baggerClearedAck : BOOL;
	calculatedCyclesPerMinute : REAL;
	sealFlattenersInUse : BOOL := TRUE;
	collisonDetectionDwell : REAL := 1.0;
	packageAtExitRunoffDwell : REAL := 1.0;
	IBDOffset : REAL := 3.0;
	pressureBarBagFeedPosition : REAL := 2.0;
	pressureBarInPosition : REAL := 0;
	feedToSealSetpoint : REAL := 0.0;
	feedToSealInUse : BOOL := FALSE;
	reverseConveyor : BOOL;
	enablePerfBreaker : BOOL;
	enablePaperBagger : BOOL;
	mailerMaterial : MAILER_MATERIAL;
	labelsQueuedUpFaultEnable : BOOL := FALSE;
	remoteCommsHeartbeatEnable : BOOL;
	auxIOSource : AuxIOSource := (Physical := TRUE);
	movePbarByHandWhileLoadingEnable : BOOL;
	paperTensionSetting : DINT := 60;
	polyTensionSetting : DINT := 50;
	cycleFirstBagFromCage : BOOL;
	trafficDetectedRunoffDwell : REAL := 1.0;
	packageOnTrunkRunoffDwell : REAL := 1.0;
	enableExitConveyorVFDFault : BOOL;
	dualPalmPressRequired : BOOL := TRUE;
	
	(*Service Stuff*)
	lpaServiceOn : BOOL;
	lpaServiceOff : BOOL;
	lpaServicePulse : BOOL;
	hpaServiceOn :BOOL;
	hpaServicePulse : BOOL;
	exitConveyorStart : BOOL;
	exitConveyorStop : BOOL;
	exitConveyorJog : BOOL;
	exitConveyorJogTime : TIME;
	exitConveyorStartDwell : BOOL;
	pressureBarService : ServiceCommands;
	loadPlateService : ServiceCommands;
	forwardLoadPlateService : ServiceCommands;
	rearLoadPlateService : ServiceCommands;
	loadShelfService : ServiceCommands;
	IBDService : ServiceCommands;
	accumulatingFunnel : ServiceCommands;
	funnelService : ServiceCommands;
	baggerHeadService : ServiceCommands;
	perfBreakerService: ServiceCommands;
	jogBagForward : BOOL;
	jogBagReverse : BOOL;
	jogPassthroughForward : BOOL;
	jogPassthroughReverse : BOOL;
	sealBarServiceCycle : BOOL;
	sealBarServiceRetract : BOOL;
	sealBarServiceExtend : BOOL;
	bagOpenFingersServiceGrab : BOOL;
	bagOpenFingersServiceRelease : BOOL;
	sealFlattenersServiceRaise : BOOL;
	sealFlattenersServiceLower : BOOL;
	sealFlattenersServiceJogIn : BOOL;
	sealFlattenersServiceJogOut : BOOL;
	sealFlattenersManualPositionSetting : REAL;
	sealFlattenersMoveToManualPos : BOOL;
	passthroughManualPositionSetting : REAL;
	passthroughMoveToManualPos : BOOL;
	factoryTestMode : BOOL;
	vacuumServiceOn : BOOL;
	vacuumServiceOff : BOOL;
	printHeadServiceRaise : BOOL;
	printHeadServiceLower : BOOL;
	externalExitConveyorStart : BOOL;
	externalExitConveyorStop : BOOL;
	externalExitConveyorJog : BOOL;
	externalExitConveyorStartDwell : BOOL;
	triggerBarcodeReaderService : BOOL;

	(*Factoy Config*)
	bofSelection : BagOpenFingersSelection := BagOpenFingersSelection.PneumaticWithBagOpenSensors;
	sealAreaOptionSelection : SealAreaOptionSelectionEnum := SealAreaOptionSelectionEnum.MotorizedSealFlatteners;
	printerSelection : LabelPrinterSelection := LabelPrinterSelection.ZebraPrinter203DPI;
	integratedExitConveyorSelection : IntegratedConveyorSelection := IntegratedConveyorSelection.RearExit;
	externalExitConveyorSelection : ExteralConveyorSelection := ExteralConveyorSelection.NotInstalled;
	feedToSealBagSelection : FeedToSealSelection := FeedToSealSelection.NotInstalled;
	packageEjectSelection : PackageEjectionSelection := PackageEjectionSelection.RearRetractingLoadPlate;
	packageEjectDisabledPosition : PackageEjectionDisabledPosition := PackageEjectionDisabledPosition.LoadingPosition;
	independentBagDeflatorSelection : BagDeflatorSelection := BagDeflatorSelection.NotInstalled;
	cycleStartButtonSelection : PalmButtonSelection := PalmButtonSelection.LightedPalmButtonAdvanced;
	barcodeVerifierSelection : BCVSelection := BCVSelection.NotInstalled;
	lightCurtainSelection : LightCurtainsSelection := LightCurtainsSelection.NotInstalled;
	baggerModelSelection : ModelSelection;
	baggerProfileSelection : BaggerProfile := BaggerProfile.Standard;
	auxIOConfig : AuxIOConfiguration;
	fillerFactorySelection : FillerSelection;
	funnelFactorySelection : FunnelSelection;
	murrIOConfigVersion : CONFIG_VERSIONS := CONFIG_VERSIONS.V_1_4;
	printerConfigVersion : CONFIG_VERSIONS := CONFIG_VERSIONS.V_1_2;
	frontFilmFeedMotorConfigVersion : CONFIG_VERSIONS := CONFIG_VERSIONS.V_1_0;
	rearUnwindMotorConfigVersion : CONFIG_VERSIONS := CONFIG_VERSIONS.V_1_3;
	sealFlattenerMotorConfigVersion : CONFIG_VERSIONS := CONFIG_VERSIONS.V_1_0;
    shakerInstalled : BOOL;
	trafficControlIONodeEnabled : BOOL;
	
	(*Warnings*)
	printerRibbonLow : Warning;
	printerNotReady : Warning;
	waitingForPrinter : Warning;
	sealBarNotAtTemperature : Warning;
	recoveryModeActive : Warning;
	jobLoadRequired : Warning;
	baggerNotReady : Warning;
	demoModeIsActive : Warning;
	factoryTestModeActive : Warning;
	machineNotTested : Warning;
	packageEjectGuardRemoved : Warning;
	bagLevelLow : Warning;
	fillerModeCycleStartOnly : Warning;
	baggerInhibited : Warning;
	packageBlockingTrunkline : Warning;
	infeedConveyorOutOfParts : Warning;
	mayCycleUnexpectedly : Warning;
	printAndApplyRibbonLow : Warning;
	printAndApplyWaitingForApply : Warning;
	printAndApplyWaitingForLabel : Warning;
	printAndApplyBypassed : Warning;
	dryCycleActive : Warning;
	lightCurtainsBlocked : Warning;
	batchCountDone : Warning;
	remoteCommsHeartbeatLost: Warning;
	stagingFunnelAndPerfBreakerEnabled : Warning;
	
	(*Faults*)
	(*Misc*)
	pressureBarState : STRING;
    heartbeat : UDINT;
    (*Counters*)
    baggerCycles : FB_CycleCounter;
	bagOpenFingerCycles : FB_CycleCounter;
	bagsMade : FB_CycleCounter;
	sealBarCycles : FB_CycleCounter;
	pressureBarCycles : FB_CycleCounter;
	passthroughChanges : FB_CycleCounter;
	loadPlateCycles : FB_CycleCounter;
	printerCycles : FB_CycleCounter;
	motorizedSealFlattenerCycles : FB_CycleCounter;
	bagOpenRetryTotal : FB_CycleCounter;
	bagsRejectedTotal : FB_CycleCounter;
	resettableBagsMade : FB_CycleCounter;
	
	(*Predictive Maint.*)
	airFilterClean : FB_PredictiveMaint := (target := 30000, count := 0, name := 'Clean Air Filter');
	driveRollerClean : FB_PredictiveMaint := (target := 20000, count := 0, name := 'Clean Drive Rollers', units := 'Inches of Bag');
	printHeadClean : FB_PredictiveMaint := (target := 10000, count := 0, name := 'Clean Print Head', units := 'Printer Cycles');
	pressureBarGuideShaftGuides : FB_PredictiveMaint := (target := 0, count := 127888, name := 'Replace Guide Shafts');
	
	pressureBarLeak : FB_CylinderLeak := (maximumStrokeTime := 5.0, name := 'Pressure Bar Stroke', units := 'Seconds');
	loadPlateLeak : FB_CylinderLeak := (maximumStrokeTime := 2.0, name := 'Load Plate Stroke', units := 'Seconds');
	
	msfHorizontalMotorTemp : FB_DriveTemp := (maxTemp := 60.0, name := 'MSF Motor Temp.', units := 'deg C');
	bagDeliveryMotorTemp : FB_DriveTemp := (maxTemp := 60.0, name := 'Bag Delivery Motor Temp.', units := 'deg C');
	passthroughMotorTemp : FB_DriveTemp := (maxTemp := 60.0, name := 'Passthrough Motor Temp.', units := 'deg C');
	
	(*Info*)
	faultActive : BOOL;
	

END_VAR

VAR_GLOBAL CONSTANT
	murrIOConfigVersionMax : CONFIG_VERSIONS := CONFIG_VERSIONS.V_1_5;
	printerConfigVersionMax : CONFIG_VERSIONS := CONFIG_VERSIONS.V_1_2;
	frontFilmFeedMotorConfigVersionMax : CONFIG_VERSIONS := CONFIG_VERSIONS.V_1_0;
	rearUnwindMotorConfigVersionMax : CONFIG_VERSIONS := CONFIG_VERSIONS.V_1_3;
	sealFlattenerMotorConfigVersionMax : CONFIG_VERSIONS := CONFIG_VERSIONS.V_1_0;
END_VAR