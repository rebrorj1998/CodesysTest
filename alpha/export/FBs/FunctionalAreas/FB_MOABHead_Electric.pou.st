(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MOABHead_Electric EXTENDS FB_BaseComponent
VAR_INPUT
    motorizedSealFlattenersMode : DEVICE_MODES := DEVICE_MODES.Auto;
    electricPressureBarMode : DEVICE_MODES := DEVICE_MODES.Auto;
	vacuumPickerMode : DEVICE_MODES;
    startCycle : BOOL;
    bagDeliveryMode : DEVICE_MODES;    // Mode of bag delivery system
    printerMode : DEVICE_MODES;        // Mode of printer
	passthroughMode : DEVICE_MODES;
	passthroughSetting : REAL;
    passthroughSettingLast : REAL;
	bagDropDelay : UINT := 1000;
END_VAR
VAR_OUTPUT
    readyToRun : BOOL;
    state : StateMachine;
END_VAR
VAR
	externalConveyorEndedOnAShelf : BOOL;
	packageAtExitONS : FB_ONS;
	packageAtExit : BOOL;
	packageAtExitTimer : Standard.TON := (PT := T#20MS);
	packageAtExitBufferTimer : Standard.TON := (PT := T#100MS);
    motorizedSealFlatteners : FB_MotorizedSealFlatteners();
	msfVerticalAxis : FB_ThreePositionCylinder();
    pressureBar : FB_MotorizedPressureBar();
	IBD : FB_MotorizedIBD();
	sealBarTempSensor : FB_IFMTempSensor();
	sealBarHeater : FB_TempController();
    startCycleONS : R_TRIG;
	enableBagOpen : BOOL;
	enableHeater : BOOL;
	enableIBDDeflate : BOOL;
	enableIBDEject : BOOL;
	factoryTestModeKeepCycling : BOOL;
	autoModeKeepCycling : BOOL;
	autoModeKeepCyclingTimer : Standard.TON;
	bagDelivery : FB_BagDelivery();
	zebraPrinter : FB_ZebraPrinterStandard;
	sealTimer : Standard.TON() := (PT := T#350MS);
	bagOpenFingerDelay : Standard.TON := (PT := T#100MS);
	bagDropTimer : Standard.TON;
	HPA : FB_MonostableMultivibrator();
	loadShelf : FB_BaseLoadPlate;
	rearLoadPlate : FB_BaseLoadPlate;
	frontLoadPlate : FB_BaseLoadPlate;
	exitConveyorRun : DelayDwellFB() := (Dwellsetting := 6000);
	externalExitConveyorRun : DelayDwellFB() := (Dwellsetting := 6000);
	IBDExtendONS : FB_ONS();
	IBDRetractONS : FB_ONS();
	startBCVONS : FB_ONS();
	bagOpenFingers : FB_BagOpenFingersWithSensors();
	bagOpenCheckDelay : Standard.TON := (PT:= T#400MS); // Delay to check if bag open
	bagOpenRetrySetting : UINT;		// Number of times to retry opening bag
	bagOpenRetryCount : UINT;		// Count of current retry attempts
	bagOpenFeedNewBagSetting : UINT; // Number of new bags to try
	bagOpenFeedNewBagCount : UINT;	// Count of new bags tried in recovery
	bagOpened : BOOL;				// Bag was Opened flag
	recoveryModeActive : BOOL; 		// Recovery Mode Active
	startCycleReqFromPalmButtons : BOOL;
	startCycleReqFromPalmButtonsONS : FB_ONS();
	pressureBarMotor : FB_AppliedMotionStepServoEIPPassthrough();
	IBDMotor : FB_AppliedMotionStepServoEIPPassthrough();
	jawClamps : FB_ThreePositionCylinder();
	homeJawPB : BOOL;
    setPassthroughPB : BOOL;
	vacuumHoldTimer : Standard.TON() := (PT := T#250MS);
	cycleTimer : TON() := (PT := T#1000S);
	cycleTime : REAL;
	bagFailedToOpen : FB_Fault(name := 'Bag Failed to Open');
	openedBagWasRemoved : FB_Fault(name := 'Opened Bag was Removed');
	safePowerFailure : FB_Fault(name := 'E-Stop/Safety Power Failure');
	palmButtonConfigError : FB_Fault(name := 'Palm Button Configuration Error');
	packageEjectGuardRemoved : FB_Fault(name := 'Package Eject Guard Removed');
	barcodeVerificationFailed : FB_Fault(name := 'Barcode Verification Failed');
	barcodeVerifierCommFail : FB_Fault(name := 'Barcode Verifier Communication Failure');
	infeedConveyorIOCommFail : FB_Fault(name := 'Infeed Conveyor IO Communication Failure');
	infeedConveyorVFDFaulted : FB_Fault(name := 'Infeed Conveyor VFD Failure');
	printAndApplyFaulted : FB_Fault(name := 'Print and Apply Faulted');
	productJammed : FB_Fault(name := 'Product Jammed on Exit Conveyor');
	printAndApplyCommFailure : FB_Fault(name := 'Print and Apply Comm Failure');
	printAndApplyWaitForLabelTimedOut : FB_Fault(name := 'Print and Apply Timed Out');
	printAndApplyPackageFailedToExit : FB_Fault(name := 'Product Failed to Exit Conveyor');
	printAndApplyPackageFailedToReachTamp : FB_Fault(name := 'Product Failed to Reach Print and Apply Tamp');
	printAndApplyPackageRemovedBeforeTamp : FB_Fault(name := 'Product Removed Before Label Tamp');
	labelsQueuedUpFault : FB_Fault(name := 'Labels Queued Up in Printer');
	sealFlattenerTimedOut : FB_Fault(name := 'Seal Flatteners Timed Out / Did Not Reach Destination');
	
	iPowerOffButtonONS : FB_ONS();
	forwardLoadPlateFaults : LoadPlateFaultsType;
	rearLoadPlateFaults : LoadPlateFaultsType;
	loadShelfFaults : LoadPlateFaultsType;
	
	LPA : DelayDwellFB();
	hpaServiceOnONS : FB_ONS;
	exitConveyorJogONS : FB_ONS;
	externalExitConveyorJogONS : FB_ONS;
	obstructionFaultONS : FB_ONS;
	hmiLight  : FB_HMILight;
	faultONS : FB_ONS;
	powerSettlingTimer : Standard.TON := (PT := T#6S);
	pressureBarCloseDelay : Standard.TON;
	_fillerDroppingProductONS : FB_ONS;
	filler : FB_Filler();
	configOutput1Pulse : FB_MonostableMultivibrator();
	configOutput2Pulse : FB_MonostableMultivibrator();
	fillerModeCycleStartOnlyPulse : FB_MonostableMultivibrator();
	collisionDetection : FB_CollisionDetection();
	murrIOBusNode : FB_MurrIO();
	funnel : FB_Funnel();
	stagingFunnel : FB_Funnel();
	barcodeVerifier : FB_BarcodeReader();
	keyenceBCV : FB_KeyenceNL20();
	cognexDM374BCV : FB_CognexDM374();
	rearMotorCommsReturned : Standard.F_TRIG();
	baggerHeadMovement : FB_BaggerHeadRaise();
	resettingActive : BOOL;
	resetTimer : Standard.TOF := (PT := T#1S);
	allMotorCommsGood : BOOL;
	basicLightedPalmButton : FB_K50_Button_BasicMode;
	advancedLightedPalmButtonOne : FB_K50_Button_AdvancedMode;
	advancedLightedPalmButtonTwo : FB_K50_Button_AdvancedMode;
	stackLight : FB_TL50_AdvancedMode;
	footSwitchONS : FB_ONS;
	IBDOutSetting: REAL;
	ezfeed : FB_EZFeed();
	printAndApply : FB_PrintAndApply();
	EIPReconfig : FB_EIPCommsConfigure();
	batchEnableONS : FB_ONS;
	estopONS : FB_ONS;
	triggerLPAWhileFeedingONS : FB_ONS();
	_runIntegratedExitConveyor : BOOL;
	_auxIOManager : FB_AuxIO;
	_auxIORemote : FB_AuxIO_RemoteComs;
	_bagGrabbedONS : Standard.R_TRIG;
	_waitForTakeupTimer : Standard.TON := (PT := T#500MS);
	_waitForSealFlattenersUpTimer : Standard.TON := (PT := T#500MS);
	_waitForPressureBarOpenDelay : TON;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: FB_MOABHead
//    Description: This is the supervisory module for the MOAB head.
//    There is one supervisory state machine for the head and 3 sub-state machines Sealing/Separating, Release/Feed, and Opening Bag
//    Created by: Ben Hess
//    Created Date: Tuesday, April 17, 2018

{region "Setup"}

// Run BaseComponentFB
SUPER^(); 
		  
// Enable/Disable nodes on comms tree dynamically
EIPReconfig(rootEIPNode := EtherNet_IP_Scanner);

// When power is returned, give machine ~5 seconds
powerSettlingTimer(IN := iEStopOK);
Globals.machinePowerOK := powerSettlingTimer.Q;
safePowerFailure.faultTrigger := NOT iEStopOK AND murrIOBusNode.ok;

// Bags Low warning
HMIData.bagLevelLow.active := iBagsLow;

// Dry Cycle Warning
HMIData.dryCycleActive.active := HMIData.enableDryCycle;

// Ethernet/IP barcode verifier from Cognex	 
startBCVONS(CLK := iPALOTAR);
cognexDM374BCV(
	inputScannerData := ADR(iBCVInputs),
	outputScannerData := ADR(oBCVOutputs),
	triggerDwell := HMIData.barcodeScanDuration,
	badScanFaultsAllowed := HMIData.barcodeBadReadFaultSetting, 
	trigger := startBCVONS.OSF AND printAndApply.runConveyorAfterApply AND NOT collisionDetection.packageHeldByCollisionDetection OR collisionDetection.triggerBarcodeScanner
);
	 
// Wait until bag is fed out before triggering barcode fail.
IF cognexDM374BCV.barcodeFault THEN
	barcodeVerificationFailed.Trigger();
END_IF 
													
// Ethernet/IP barcode verifier from Keyence
keyenceBCV(
	ptrEIPInputs:= ADR(keyenceBCVInputs), 
	ptrEIPOutputs:= ADR(keyenceBCVOutputs), 
);	 
		 
// Barcode Verifier interface to printer
barcodeVerifier(
	enable := (HMIData.barcodeVerifierSelection = BCVSelection.LaserScanner AND HMIData.barcodeVerifierInUse),
	readGoodInput := keyenceBCV.goodRead,
	distanceToScan := HMIData.barcodeScanDistance,
	feedSpeed := TO_REAL(HMIData.printSpeed),
	positionOffset := HMIData.barcodeStartPosition,
	badReadFaultCountSetting := HMIData.barcodeBadReadFaultSetting,
	triggerScannerOutput => keyenceBCV.triggerInput
);
	 
CASE HMIData.barcodeVerifierSelection OF
		 
	BCVSelection.NotInstalled:
		keyence_BCV.Enable := FALSE;
		DM374_BCV.Enable := FALSE;
		HMIData.barcodeBadReadCount := 0;
		HMIData.barcodeGoodReadCount := 0;
			 
	BCVSelection.LaserScanner:
		Keyence_BCV.Enable := TRUE;
		DM374_BCV.Enable := FALSE;
		HMIData.barcodeLastReadString := keyenceBCV.lastReadData;
		HMIData.barcodeBadReadCount := barcodeVerifier.currentBadReadCount;
		HMIData.barcodeGoodReadCount := barcodeVerifier.currentGoodReadCount;
		IF Keyence_BCV.eState <> IoDrvEthernetIP.AdapterState.RUNNING THEN 
			barcodeVerifierCommFail.Trigger();
		END_IF
			 
	BCVSelection.TwoDimensional:
		Keyence_BCV.Enable := FALSE;
		DM374_BCV.Enable := TRUE;
		IF cognexDM374BCV.enable THEN
			HMIData.barcodeLastReadString := cognexDM374BCV.lastReadData;
			HMIData.barcodeBadReadCount := cognexDM374BCV.badReadCount;
			HMIData.barcodeGoodReadCount := cognexDM374BCV.goodReadCount;
		END_IF
		IF DM374_BCV.eState <> IoDrvEtherNetIP.AdapterState.RUNNING OR cognexDM374BCV.triggerFeedbackFault THEN
			barcodeVerifierCommFail.Trigger();		 
		END_IF
		cognexDM374BCV.enable := HMIData.barcodeVerifierInUse AND HMIData.baggerModelSelection = ModelSelection.Pro18_1183;
END_CASE
	 
// Raise/Lower bagger head logic
// Indications and commands from HMI
HMIData.baggerHeadService.extendedFeedback := NOT iHeadRaised;
HMIData.baggerHeadService.retractedFeedback := NOT iHeadLowered;
IF HMIData.baggerHeadService.retractedFeedback THEN
	HMIData.baggerHeadService.retractCommand := FALSE;
END_IF
IF HMIData.baggerHeadService.extendedFeedback THEN
	HMIData.baggerHeadService.extendCommand := FALSE;
END_IF
baggerHeadMovement(
	raiseCommand:= HMIData.baggerHeadService.extendCommand, 
	lowerCommand:= HMIData.baggerHeadService.retractCommand, 
	raiseLimitSwitch:= HMIData.baggerHeadService.extendedFeedback, 
	lowerLimitSwitch:= HMIData.baggerHeadService.retractedFeedback, 
	runMotorOutput=> oRunBaggerHeadMotor, 
	motorDirectionOutput=> oBaggerHeadMotorDir);
	 
// Option setup and factory config  
IF HMIData.resetAverageCycleTime THEN
	HMIData.averageCycleTime := 0;
	HMIData.resetAverageCycleTime := FALSE;
END_IF
HMIData.lastCycleTime := cycleTime;

HMIData.printerNotReady.active := (NOT printerReady AND zebraPrinter.enable) OR (printAndApply.printerNotReady AND printAndApply.enable);
HMIData.waitingForPrinter.active := (zebraPrinter.state = PRINTER_STATES.WaitingForData AND state.sb.releaseFeed = RELEASE_FEED_STATES.WaitForPrinter) 
									OR (printAndApply.waitingForPrinter AND printAndApply.enable)
									OR (zebraPrinter.state = PRINTER_STATES.WaitingForData AND state.sb.printOutOfCycle = PRINT_OUT_OF_CYCLE_STATES.WaitForPrinter);

bagOpenRetrySetting := HMIData.bagOpenRetrySetting;
HMIData.bagOpenRetryCount := bagOpenRetryCount;
	 
// Run bus node		  
murrIOBusNode(
	enable:= , 
	headNodeEnabled:= TRUE, 
	guardNodeEnabled:= (HMIData.cycleStartButtonSelection = PalmButtonSelection.SinglePalmButton 
						OR HMIData.cycleStartButtonSelection = PalmButtonSelection.DualPalmButton
						OR (HMIData.funnelFactorySelection <> FunnelSelection.NotInstalled)), 
	printerNodeEnabled:= , 
	dischargeNodeEnabled:= TRUE, 
	auxIONodeEnabled:= , 
	configVersion:= HMIData.murrIOConfigVersion, 
	ptrMachineOptionsManagementOutputs:= ADR(oMOMConfig), 
	ptrSystemStatusInputs:= ADR(iMurrSystemState));

// Setup of Motorized seal flattener motor and function block
msfVerticalAxis(extendOutput => oSealFlatDown, retractOutput => oSealFlatUp);
msfVerticalAxis.Execute();
motorizedSealFlatteners(sealFlattenersVerticalAxis := msfVerticalAxis,
						jogIn := HMIData.sealFlattenersServiceJogIn,
						jogOut := HMIData.sealFlattenersServiceJogOut,
						raiseService := HMIData.sealFlattenersServiceRaise,
						lowerService := HMIData.sealFlattenersServiceLower,
						moveToManualSetpoint := HMIData.sealFlattenersMoveToManualPos,
						manualPosSetpoint := HMIData.sealFlattenersManualPositionSetting,
						sealFlattenerMotorCommFailInput := MSFMotor.eState <> IoDrvEthernetIP.AdapterState.RUNNING AND MSFMotor.Enable,
						timeoutFault => sealFlattenerTimedOut.faultTrigger,
						position => HMIData.sealFlattenersPosition
);
motorizedSealFlatteners.Mode := motorizedSealFlattenersMode;
motorizedSealFlatteners.enable := (HMIData.sealAreaOptionSelection = SealAreaOptionSelectionEnum.MotorizedSealFlatteners) AND HMIData.sealFlattenersInUse;
MSFMotor.Enable := (HMIData.sealAreaOptionSelection = SealAreaOptionSelectionEnum.MotorizedSealFlatteners);
	 
pressureBarMotor(
	ptrEIPInputs := ADR(jawPasstrhoughMotorInputs),
    ptrEIPOutputs := ADR(jawPasstrhoughMotorOutputs),
    stepsPerInchSetpoint := Globals.STEPS_PER_INCH_TFBelt,
	reversePolarity := FALSE,
	defaultCurrentSetpoint := 500,
	commFail := Pbar_ServoEIP.eState <> IoDrvEthernetIP.AdapterState.RUNNING,
	isHomable := TRUE);			
pressureBarMotor.Execute();

jawClamps(
	mode:= , 
	extendedStatus=> , 
	retractedStatus=> , 
	extendOutput=> oJawClampExtend, 
	retractOutput=> oJawClampRetract);	 
	 
pressureBar(
	enable:= , 
	openedPositionBuffer:= HMIData.pressureBarPositionBuffer, 
	iPressureBarClosed:= iJawClearToClamp, 
	iPressureBarNotObstructed:= TRUE, 
	iBaggerEnableButton:= , 
	iJawClampExtended:= iJawClampsExtended, 
	iJawCLampRetracted:= iJawClampsRetracted, 
	pbarOutSetting:= HMIData.passthroughSetting, 
	pbarInSetting:= HMIData.pressureBarInPosition, 
	pbarBagFeedSetting:= HMIData.pressureBarBagFeedPosition,
	disableFaults:= , 
	extendJawClamp:= , 
	retractJawClamp:= , 
	extendJaw:= , 
	retractJaw:= , 
	faults => , 
	failToClampLeft=> , 
	failToReleaseLeft=> , 
	failToClampRight=> , 
	failToReleaseRight=> , 
	state=> , 
	actualPosition=> HMIData.passthroughPosition,
	pressureBarClosed => HMIData.pressureBarService.retractedFeedback,
	pressureBarOpen => HMIData.pressureBarService.extendedFeedback, 
	jawClamps:= jawClamps, 
	pbarMotor:= pressureBarMotor);
pressureBar.Mode := electricPressureBarMode;

// Run bag delivery 
bagDelivery(
	jogForwardPB := HMIData.jogBagForward,
	jogReversePB := HMIData.jogBagReverse,
	feedToSealSetpoint := HMIData.feedToSealSetpoint,
	bagLengthSetpoint := HMIData.bagLength,	 
	printVelocitySetpoint := HMIData.printSpeed,
	printLengthSetpoint := HMIData.printLength,
	sealOffsetSetpoint := HMIData.bagSkirtLength,
	reverseVelocitySetpoint := TO_INT(HMIData.bagReverseSpeed),
	feedVelocitySetpoint := TO_INT(HMIData.bagForwardSpeed),
	printOffsetSetpoint := HMIData.printOffset,	
	reverseToPrintheadRequired := zebraPrinter.enable AND HMIData.printerCycleSelection = PrinterCycleSelection.PrintWhileFeeding,
	bagFeedMasterMotorCommFailInput := Bag_Delivery_EIP_Motor.eState <> IoDrvEthernetIP.AdapterState.RUNNING,
	bagFeedRearMotorCommFailInput := Bag_Delivery_Rear_Motor.eState <> IoDrvEthernetIP.AdapterState.RUNNING,
	stepsPerInchSetting := Globals.STEPS_PER_INCH_PRO24_BAG_DELIVERY,
	velocityMultiplier := Globals.VELOCITY_IPS_MULTIPLIER_ELECTRIC,
	rearMotorConfigVersion := HMIData.rearUnwindMotorConfigVersion	 
);
bagDelivery.Mode := bagDeliveryMode;

CASE HMIData.printerSelection OF
		 
	LabelPrinterSelection.NotInstalled:				//
													zebraPrinter.enable := FALSE;
													printAndApply.enable := FALSE;
													Panther_PA.Enable := FALSE;
													murrIOBusNode.printerNodeEnabled := FALSE;
	
	LabelPrinterSelection.ZebraPrinter203DPI, 			   
		LabelPrinterSelection.ZebraPrinter300DPI:	//
													zebraPrinter.enable := HMIData.printerInUse;
													printAndApply.enable := FALSE;
													Panther_PA.Enable := FALSE;
													murrIOBusNode.printerNodeEnabled := TRUE;
														 
			
	LabelPrinterSelection.PrintAndApply203DPI,
		LabelPrinterSelection.PrintAndApply300DPI:			//
		 											zebraPrinter.enable := FALSE;
													Panther_PA.Enable := TRUE;
													printAndApply.enable := HMIData.printerInUse;
													murrIOBusNode.printerNodeEnabled := FALSE;
END_CASE

// Run Zebra Printer
//
zebraPrinter(ribbonEncoderState := iPrinterRibbonEncoder, oLowerPrintHead => oPrintHeadDown);
zebraPrinter.Mode := printerMode;

// Disable out of cycle priting if not possible
IF NOT HMIData.printOutOfCycleEnable THEN 
	HMIData.printerCycleSelection := PrinterCycleSelection.PrintWhileFeeding;
END_IF

IF HMIData.activateDemoMode THEN
	HMIData.demoModeIsActive.active := TRUE;
	zebraPrinter.autoSendLabel := TRUE;
ELSE
	HMIData.demoModeIsActive.active := FALSE;
	zebraPrinter.autoSendLabel := FALSE;
END_IF

IF HMIData.baggerClearedAck THEN
	HMIData.baggerClearedAck := FALSE;
	printAndApply.ClearedBagAck();
END_IF

//	 
packageAtExitTimer(IN := iPackageAtExit);

//	  
printAndApply(
	enable:= , 
	bypass := NOT bagOpened,
	baggerFaulted:= HMIData.faultActive, 
	baggerInCycle:= HMIData.inCycle, 
	dataReady:= iPAOnlineDataReady, 
	LOTAR:= iPALOTAR, 
	faultInput:= NOT iPAFaulted,
	PACycleComplete:= iPACycleComplete, 
	applicatorHome:= iPAApplicatorHome, 
	heartbeat:= iPAHeartbeat, 
	productAtApplicatorSensor:= NOT iConveyorClear, 
	conveyorClearAfterCollision := collisionDetection.conveyorCleared,
	exemptFaultsActive :=  pressureBar.faults.obstructionDetected.active OR barcodeVerificationFailed.active,
	packageAtExitSensor := NOT iPackageAtExit,
	packageHeldAtExitSensor := collisionDetection.packageHeldByCollisionDetection,
	exitConveyorRunAfterPASetting := HMIData.printAndApplyConveyorDwell,
	waitForPrinterFaultSetting := HMIData.printAndApplyWaitForLabelTimeout,
	packageExitTimeSetting := HMIData.printAndApplyConveyorDwell,
	packageToTampTimeSetting := HMIData.exitConveyorDwell,
	tampDelayWithLOTAR :=  HMIData.printAndApplyTriggerDelayWithLOTAR,
	tampDelayWithoutLOTAR := HMIData.printAndApplyTriggerDelayWithoutLOTAR,
	commFail=> printAndApplyCommFailure.faultTrigger, 
	faultedStatus=> printAndApplyFaulted.faultTrigger, 
	waitForPrintFault=> printAndApplyWaitForLabelTimedOut.faultTrigger,
	jammedFault=> productJammed.faultTrigger,
	triggerOutput=> oPATrigger1,
	resetOutput=> oPAReset, 
	clearOutBaggerIndicaiton => HMIDAta.baggerNeedsClearing,
	labelsInQueue=> labelsQueuedUpFault.faultTrigger
);
	 
collisionDetection(
	enable := HMIData.auxIOConfig.cfgInput1Selection = AuxInputSelection.CollisionDetection,
	collisionDetected := iAuxConfigInput1,
	collisionDetectedDwell := HMIData.collisonDetectionDwell,
	collisionEngineRunoffDwell := HMIData.packageAtExitRunoffDwell,
	multiplePackagesHeld := printAndApply.state = PRINT_AND_APPLY_STATES.Inhibited,
	conveyorsActive := printAndApply.runConveyorAfterApply,
	packageAtExit := NOT iPackageAtExit,
	packageHeldByCollisionDetection => HMIData.packageBlockingTrunkline.active
);
	 
// Run funnel
funnel(
	openingDelay := HMIData.funnelOpenDelay, 
	openingDwell := HMIData.funnelOpeningTime,
	closingDwell := HMIData.funnelClosingTime,
	iOpened := iFunnelOpened, 
	iClosed := iFunnelClosed,  
	oClose => oFunnelClose, 
	oOpen => oFunnelOpen
);

// 2nd Stage Funnel
stagingFunnel(
	openingDelay := HMIData.stagingFunnelOpenDelay, 
	openingDwell := HMIData.stagingFunnelOpeningTime,
	closingDwell := HMIData.stagingFunnelClosingTime,
	iOpened := iStagingFunnelOpened, 
	iClosed := iStagingFunnelClosed,  
	oClose => oStagingFunnelClose, 
	oOpen => oStagingFunnelOpen
);

CASE HMIData.funnelFactorySelection OF
	FunnelSelection.NotInstalled:
		// Disable both funnels
		funnel.enable := FALSE;
		stagingFunnel.enable := FALSE;
		
	FunnelSelection.FunnelWithSensors:
		//
		funnel.enable := HMIData.funnelInUse;
		funnel.feedback := eActuatorFeedbackType.Both;
		stagingFunnel.enable := FALSE;
	
	FunnelSelection.FunnelWithoutSensors:
		//
		funnel.enable := HMIData.funnelInUse;
		funnel.feedback := eActuatorFeedbackType.None;
		stagingFunnel.enable := FALSE;
		
	FunnelSelection.TwoStageFunnelWithSensors:

		_fillerDroppingProductONS(CLK := filler.droppingProduct);
		IF _fillerDroppingProductONS.OSR THEN
			stagingFunnel.Open();
		ELSIF _fillerDroppingProductONS.OSF THEN
			stagingFunnel.Close();
		END_IF

		//
		funnel.enable := HMIData.funnelInUse;
		funnel.feedback := eActuatorFeedbackType.Both;
		stagingFunnel.enable := HMIData.funnelInUse;
		stagingFunnel.feedback := eActuatorFeedbackType.Both;
			 
	FunnelSelection.BagLoadingTray:
		funnel.enable := HMIData.funnelInUse;
		funnel.feedback := eActuatorFeedbackType.Both;
		stagingFunnel.enable := FALSE;
			 
END_CASE
//
//
sealBarTempSensor(
	busNodeOK := murrIOBusNode.ok,
	ptrTemperatureBytes := ADR(iHeaterBarTempInputs)
);
	 
//
IF sealBarTempSensor.reconfigureIO THEN
	murrIOBusNode.restartBusnodePulse.Trigger();		 
END_IF

//	 
sealBarHeater(
	enable := NOT safePowerFailure.active,
	temperatureSensor := sealBarTempSensor,
	temperatureSetpoint := TO_REAL(HMIData.sealBarTemperatureSetting),
	heaterPulse => 	oHeaterPulse,
	currentTemp => HMIData.sealBarTemperature
);	  

{region "timers"}
// Timers
sealTimer();
bagOpenFingerDelay();
vacuumHoldTimer(PT := TO_TIME(HMIData.vacuumDwell * 1000));
bagOpenCheckDelay();
bagDropTimer(PT := TO_TIME((HMIData.loadPlateDelay * 1000) + (HMIData.bagDropTime * 1000)));
{endregion}
		  
// Setup of HPA and load plate.  Use .Trigger() to run.
HPA.DwellSetting := TO_UINT(HMIData.hpaDwell * 1000);
HPA(Q => oHPAOn);
hpaServiceOnONS(CLK := HMIData.hpaserviceOn);

triggerLPAWhileFeedingONS(CLK := state.sb.releaseFeed = RELEASE_FEED_STATES.MovingJawOutAndFeedingBag);
IF HMIData.lpaDuringBagFeedEnable AND triggerLPAWhileFeedingONS.OSR THEN
	LPA.DwellSetting := TO_DINT(((bagDelivery.remainingLength - HMIData.bagSkirtLength) / TO_REAL(HMIData.bagForwardSpeed)) * 1000.0);
	LPA.Trigger();
END_IF
LPA(Q => oLPAOn);
	 
CASE HMIData.independentBagDeflatorSelection OF
	BagDeflatorSelection.NotInstalled:					// Disable IBD
		 													enableIBDDeflate := FALSE;
															enableIBDEject := FALSE;
	
	BagDeflatorSelection.IBDStandard:	// Enable IBD
															IF HMIData.IBDDeflateDwellTime <> 0 THEN
																enableIBDDeflate := TRUE;
															ELSE
																enableIBDDeflate := FALSE;
															END_IF
															
															IF HMIData.IBDPackageEjectAssistDwellTime <> 0 THEN
																enableIBDEject := TRUE;
															ELSE
																enableIBDEject := FALSE;
															END_IF
	 														
																 
	BagDeflatorSelection.IBDWithHingedPlate:	// Enable IBD with Hinged Plate
															
																 
	BagDeflatorSelection.MotorizedIBD:			// Enable motorized IBD
															IF HMIData.IBDDeflateDwellTime <> 0 THEN
																enableIBDDeflate := TRUE;
															ELSE
																enableIBDDeflate := FALSE;
															END_IF
															
															IF HMIData.IBDPackageEjectAssistDwellTime <> 0 THEN
																enableIBDEject := TRUE;
															ELSE
																enableIBDEject := FALSE;
															END_IF
END_CASE
		
(*  
CASE HMIData.bofSelection OF
	BagOpenFingersSelection.NotInstalled:					// Disable Bag Open
		 													enableBagOpen := FALSE;
															
	
	BagOpenFingersSelection.PneumaticWithBagOpenSensors:	// Enable Bag Open
															enableBagOpen := TRUE;
	
END_CASE
	 *)
		  enableBagOpen := hmidata.bagOpenEnable;

CASE HMIData.cycleStartButtonSelection OF
	PalmButtonSelection.NotInstalled:					// Dont' allow input to start bagger cycle
		 												startCycleReqFromPalmButtons := FALSE;
		 
	PalmButtonSelection.SinglePalmButton:				// Start using one side only
		 												startCycleReqFromPalmButtons := iRightPalmButton;
														
														// Trigger fault if left palm button is seen - should be set up for dual!	 
														IF iLeftPalmButton THEN
															palmButtonConfigError.Trigger();		 
														END_IF
		 
	PalmButtonSelection.DualPalmButton:					// Both buttons must be pressed
		 												startCycleReqFromPalmButtons := iRightPalmButton AND iLeftPalmButton;
															 
	PalmButtonSelection.LightedPalmButton:				
		// Lighted Murr palm button input comes from IO Link
		startCycleReqFromPalmButtons := iMurrTouchButtonOneStatus.0 OR iMurrTouchButtonTwoStatus.0;
		basicLightedPalmButton(
			baggerReady:= readyToRun AND NOT HMIData.sealBarNotAtTemperature.active, 
			baggerFaulted:= HMIData.faultActive, 
			baggerInCycle:= HMIData.inCycle, 
		);
		oMurrTouchbuttonOneState := oMurrTouchButtonTwoState := basicLightedPalmButton.IOLinkStateOutput;													 
														
    PalmButtonSelection.LightedPalmButtonAdvanced, PalmButtonSelection.DualLightedPalmButtonAdvanced:		
		// Lighted Murr palm button input comes from IO Link
		startCycleReqFromPalmButtons := iMurrTouchButtonOneStatus.0 OR iMurrTouchButtonTwoStatus.0;														 
		advancedLightedPalmButtonOne(
			IOLinkData := ADR(oMurrTouchButtonOneIOLinkOutputs),
			baggerReady := readyToRun AND NOT HMIData.sealBarNotAtTemperature.active,
			baggerFaulted := HMIData.faultActive,
			baggerInCycle := HMIData.inCycle,
			baggerExternalInhibited := printAndApply.state = PRINT_AND_APPLY_STATES.Inhibited,
			baggerHeatingUp := HMIDAta.sealBarNotAtTemperature.active AND sealBarHeater.heating
		);	
        IF HMIData.cycleStartButtonSelection = PalmButtonSelection.DualLightedPalmButtonAdvanced THEN
			advancedLightedPalmButtonTwo(
				IOLinkData := ADR(oMurrTouchButtonTwoIOLinkOutputs),
				baggerReady := readyToRun AND NOT HMIData.sealBarNotAtTemperature.active,
				baggerFaulted := HMIData.faultActive,
				baggerInCycle := HMIData.inCycle,
				baggerExternalInhibited := printAndApply.state = PRINT_AND_APPLY_STATES.Inhibited,
				baggerHeatingUp := HMIDAta.sealBarNotAtTemperature.active AND sealBarHeater.heating
			);	
		END_IF					  									 
END_CASE
startCycleReqFromPalmButtonsONS(CLK := startCycleReqFromPalmButtons);	 
// Stack Light active only if no 2nd palm button selected
// Stack Light active only if no 2nd palm button selected
IF HMIData.cycleStartButtonSelection <> PalmButtonSelection.DualLightedPalmButtonAdvanced THEN
	stackLight(
		IOLinkData:= ADR(oMurrStackLightOutputs), 
		baggerReady := readyToRun AND NOT HMIData.sealBarNotAtTemperature.active AND NOT HMIData.faultActive ,
		baggerFaulted := HMIData.faultActive,
		baggerInCycle := HMIData.inCycle,
		baggerExternalInhibited := printAndApply.state = PRINT_AND_APPLY_STATES.Inhibited ,
		bagsLow:= HMIData.bagLevelLow.active, 
		bagOpenRetryActive:= bagOpenRetryCount <> 0,
		baggerHeatingUp := HMIDAta.sealBarNotAtTemperature.active AND sealBarHeater.heating
	);	 
END_IF

		 
_auxIOManager(
	state := state,
	configIn1 := iAuxConfigInput1, 
	configIn2 := iAuxConfigInput2,
	bagsLow := HMIData.bagLevelLow.active,
	faultActive := HMIData.faultActive,
	inhibitCycle := printAndApply.inhibitCycle,
	printerDataReady := printerDataReady,
	waitingForFiller := filler.waitingForFiller,
	runExitConveyor := oRunExternalExitConveyor,
	fillerType := HMIData.fillerFactorySelection,
	factorySelection := HMIData.auxIOConfig,
	installed => murrIOBusNode.auxIONodeEnabled,
	baggerOK => oAuxBaggerOk,
	readyForFiller => oAuxReadyForFiller,
	inhibitBagger => HMIData.baggerInhibited.active,
	configOut1 => oAuxConfigOut1,
	configOut2 => oAuxConfigOut2,
);
	 
		  
_auxIORemote(
	state := state,	
	bagsLow := HMIData.bagLevelLow.active,
	faultActive := HMIData.faultActive,
	inhibitCycle := printAndApply.inhibitCycle,
	printerDataReady := printerDataReady,
	waitingForFiller := filler.waitingForFiller,
	runExitConveyor := oRunExternalExitConveyor,	
	activeFaults := GlobalObjects.CollectionOfActiveFaults.ObjNames,
	baggerOK => RemoteComs.baggerOK,
	inhibitBagger => HMIData.baggerInhibited.active,
);
		 

// Filler and EZFeed conveyor setup
CASE HMIData.fillerFactorySelection OF
	FillerSelection.NotInstalled:					// No filler
		// No filler
		 											filler.enable := FALSE;
													filler.activateFiller := FALSE;	
													HMIData.fillerEnable := FALSE;
													ezfeed.enable := FALSE;
													fillerModeCycleStartOnlyPulse.Reset();
													Infeed_Conveyor_IO.Enable := FALSE;
		 
	FillerSelection.StandardFiller:					// Only enable filler if Aux IO is enabled
		// Only enable filler if Aux IO is enabled
		 											filler.enable := (HMIData.auxIOConfig.factorySelection = AuxiliaryIOSelection.AuxIOStandard);
													Infeed_Conveyor_IO.Enable := FALSE;
														 
	FillerSelection.EZFeed:							
		filler.enable := TRUE;
		 											ezfeed.enable := TRUE;
													Infeed_Conveyor_IO.Enable := TRUE;
													
END_CASE 	 

ezfeed(
	enable:= , 
	baggerFaulted:= HMIData.faultActive, 
	enableEZFeed:= HMIData.fillerEnable, 
	continuousModeEnable:= HMIData.infeedConveyorRunningMode, 
	partsCountingModeEnable:= HMIData.infeedConveyorCountingMode, 
	flightPresentSensor:= iInfeedFlightSensor, 
	partPresentSensor:= NOT iLightCurtainsClear AND HMIData.lightCurtainSelection = LightCurtainsSelection.LoadingAreaLightCurtains, 
	waitingForFiller:= filler.waitingForFiller AND (NOT HMIData.stopMachine) AND NOT HMIdata.batchCountDone.active, 
	indexDwellSetting:= HMIData.infeedIndexDwellTimer, 
	flightTarget:= HMIData.infeedFlightCountTarget, 
	partsTarget:= HMIData.infeedPartsCountTarget, 
	emptyPartsWarningSetting:= HMIData.infeedEmptyPartsSetting, 
	restartFromEmptyParts:= HMIData.initiateCycle, 
	state=> , 
	runVFD=> oRunInfeedVFD, 
	flightCount=> HMIData.infeedFlightCountActual, 
	partsCount=> HMIData.infeedPartsCountActual, 
	emptyPartsWarningCount=> HMIData.infeedEmptyPartsActual, 
	emptyPartsWarning=> HMIData.infeedConveyorOutOfParts.active,
	EZFeedDone=> );

IF HMIData.fillerFactorySelection = FillerSelection.EZFeed THEN
	Infeed_Conveyor_IO.Enable := TRUE; 

	IF Infeed_Conveyor_IO.eState <> IoDrvEthernetIP.AdapterState.RUNNING THEN 
		infeedConveyorIOCommFail.Trigger();
	END_IF
ELSE
	Infeed_Conveyor_IO.Enable := FALSE;
END_IF
	 
infeedConveyorVFDFaulted.faultTrigger := (HMIData.fillerFactorySelection = FillerSelection.EZFeed) AND ezfeed.enableEZFeed AND NOT iInfeedVFDNotFaulted;
		 
fillerModeCycleStartOnlyPulse.DwellSetting := 4000;
fillerModeCycleStartOnlyPulse(Q => HMIData.fillerModeCycleStartOnly.active);
filler(
	enable:= ,	
	inCycle := HMIData.inCycle,
	fillerTrigger:= iAuxFillerTrigger OR ezfeed.EZFeedDone, 
	activateFiller:= HMIData.fillerEnable, 
	dropTime:= HMIData.fillerDropTime,
	state=> , 
	fillerModeActive=> , 
	waitingForFiller=> ,
	cycleBagRequest=> , 
	cycleBaggerToActivateFiller=> , 
	notReady=> 
);
	 
IF filler.activateFiller AND NOT filler.cycleBaggerToActivateFiller.active THEN
	IF HMIData.initiateCycle OR startCycleReqFromPalmButtons THEN
		fillerModeCycleStartOnlyPulse.Trigger();
	END_IF
END_IF

//
loadShelf(
	faultActive := HMIData.faultActive,
	switchedPowerON := iEStopOK,
	inUse := HMIData.loadPlateInUse,
    shakerEnable := HMIData.shakerInstalled,
	shakeStart := HMIData.loadShelfShakerStart,
	shakerDwell := HMIData.loadShelfShakerDwell,
	shakerDelay := HMIData.loadShelfShakerDelay,
	shakerOnDwell := HMIData.loadShelfShakerOnDuration,
	shakerOffDwell := HMIData.loadShelfShakerOffDuration,
	disabledPosition := HMIData.packageEjectDisabledPosition,
	dischargeOnFault := printAndApply.enable,
	faultsEnabled := FALSE,
	moveToLoadingPositon => oLoadShelfUp,
	moveToDischargePosition => oLoadShelfDown
);		 
HMIData.loadShelfService.extendedFeedback := rearLoadPlate.inLoadingPosition;
HMIData.loadShelfService.retractedFeedback := rearLoadPlate.inDischargePosition;

//	 
rearLoadPlate(
	faultActive := HMIData.faultActive,
	switchedPowerON := iEStopOK,
	inUse := HMIData.loadPlateInUse,
	inLoadingPosition := iLoadPlateExtended,
	inDischargePosition := iLoadPlateRetracted,
    shakerEnable := HMIData.shakerInstalled,
	shakeStart := HMIData.rearloadPlateShakerStart,
	shakerDwell := HMIData.rearLoadPlateShakerDwell,
	shakerDelay := HMIData.rearLoadPlateShakerDelay,
	shakerOnDwell := HMIData.rearLoadPlateShakerOnDuration,
	shakerOffDwell := HMIData.rearLoadPlateShakerOffDuration,
	disabledPosition := HMIData.packageEjectDisabledPosition,
	dischargeOnFault := printAndApply.enable,
	moveToLoadingPositon => oloadPlateExtend,
	moveToDischargePosition => oLoadPlateRetract,
	failedToExtend => rearLoadPlateFaults.failedToLoad.faultTrigger,
	failedToRetract => rearLoadPlateFaults.failedToDischarge.faultTrigger
);		 
HMIData.rearLoadPlateService.extendedFeedback := HMIData.loadPlateService.extendedFeedback := rearLoadPlate.inLoadingPosition;
HMIData.rearLoadPlateService.retractedFeedback := HMIData.loadPlateService.retractedFeedback :=  rearLoadPlate.inDischargePosition;

//	 
frontLoadPlate(
	faultActive := HMIData.faultActive,
	switchedPowerON := iEStopOK,
	inUse := HMIData.loadPlateInUse,
	inLoadingPosition := iFrontLoadPlateRetracted,
	inDischargePosition := iFrontLoadPlateExtended,
	//triggerDwell := HMIData.loadPlateDwell,
	//triggerDelay := HMIData.loadPlateDelay,
    shakerEnable := HMIData.shakerInstalled,
	shakeStart := HMIData.frontloadPlateShakerStart,
	shakerDwell := HMIData.frontLoadPlateShakerDwell,
	shakerDelay := HMIData.frontLoadPlateShakerDelay,
	shakerOnDwell := HMIData.frontLoadPlateShakerOnDuration,
	shakerOffDwell := HMIData.frontLoadPlateShakerOffDuration,
	disabledPosition := HMIData.packageEjectDisabledPosition,
	dischargeOnFault := printAndApply.enable,
	moveToLoadingPositon => oFrontLoadPlateToLoad,
	moveToDischargePosition => oFrontLoadPlateToDischarge,
	failedToExtend => forwardLoadPlateFaults.failedToLoad.faultTrigger,
	failedToRetract => forwardLoadPlateFaults.failedToDischarge.faultTrigger
);		 
HMIData.forwardLoadPlateService.extendedFeedback := frontLoadPlate.inLoadingPosition;
HMIData.forwardLoadPlateService.retractedFeedback := frontLoadPlate.inDischargePosition;

CASE HMIData.packageEjectSelection OF
	PackageEjectionSelection.NotInstalled:				// Disable All
		 												loadShelf.enable := FALSE;	
														rearLoadPlate.enable := FALSE;
														frontLoadPlate.enable := FALSE;
														rearLoadPlate.faultsEnabled := FALSE;
														frontLoadPlate.faultsEnabled := FALSE;	
		 
	PackageEjectionSelection.RearRetractingLoadPlate:	// Enable Rear Retracting Load Plate
		 												loadShelf.enable := FALSE;	
														rearLoadPlate.enable := TRUE;
														frontLoadPlate.enable := FALSE;
														rearLoadPlate.faultsEnabled := powerSettlingTimer.Q;
														frontLoadPlate.faultsEnabled := FALSE;			
														rearLoadPlate.triggerDelay := HMIData.loadPlateDelay;
														rearLoadPlate.triggerDwell := HMIData.loadPlateDwell;
	
	PackageEjectionSelection.LabelSideUp:				// Enable All
		 												loadShelf.enable := TRUE;	
														rearLoadPlate.enable := TRUE;
														frontLoadPlate.enable := TRUE;
														rearLoadPlate.faultsEnabled := powerSettlingTimer.Q;
														frontLoadPlate.faultsEnabled := state.head >= HEAD_STATES.ReleaseAndFeedBag;
                                                        rearLoadPlate.triggerDelay := HMIData.loadPlateDelay;
														rearLoadPlate.triggerDwell := HMIData.loadPlateDwell + HMIData.loadPlateDelay;
														loadShelf.triggerDelay := HMIData.loadShelfDelay;
														loadShelf.triggerDwell := HMIData.loadShelfDwell;
														frontLoadPlate.triggerDelay := HMIData.loadShelfDelay;
														frontLoadPlate.triggerDwell := HMIData.loadShelfDwell;
															 
	PackageEjectionSelection.RearRetractWithRetractShelf:   
														// Enable Rear Retracting Load Plate and Shelf
		 												loadShelf.enable := TRUE;	
														rearLoadPlate.enable := TRUE;
														frontLoadPlate.enable := FALSE;
														rearLoadPlate.faultsEnabled := powerSettlingTimer.Q;
														frontLoadPlate.faultsEnabled := FALSE;
														rearLoadPlate.triggerDelay := HMIData.loadPlateDelay;
														rearLoadPlate.triggerDwell := HMIData.loadPlateDwell;
														loadShelf.triggerDelay := HMIData.loadShelfDelay;
														loadShelf.triggerDwell := HMIData.loadShelfDwell;
END_CASE	
	 

//  
exitConveyorRun();
exitConveyorRun.DwellSetting := TO_DINT(HMIData.exitConveyorDwell * 1000);
exitConveyorJogONS(CLK := HMIData.exitConveyorJog);

oRunExitConveyor := ((exitConveyorRun.Q OR collisionDetection.runExitConveyor OR (printAndApply.runConveyorAfterApply AND NOT printAndApply.inhibitConveyor)) AND HMIData.integratedExitConveyorSelection = IntegratedConveyorSelection.RearExit);
	 
_runIntegratedExitConveyor := ((exitConveyorRun.Q OR collisionDetection.runExitConveyor OR (printAndApply.runConveyorAfterApply AND NOT printAndApply.inhibitConveyor)) AND HMIData.integratedExitConveyorSelection = IntegratedConveyorSelection.RearExit);	 
oRunExitConveyorForward := _runIntegratedExitConveyor AND NOT (HMIData.reverseConveyor OR _auxIOManager.reverseConveyor);
oRunExitConveyor := oRunExitConveyorForward;
oRunExitConveyorReverse := _runIntegratedExitConveyor AND (HMIData.reverseConveyor OR _auxIOManager.reverseConveyor OR _auxIORemote.reverseConveyor);
 
externalExitConveyorRun();
externalExitConveyorRun.DwellSetting := TO_UINT(HMIData.externalExitConveyorDwell * 1000);
externalExitConveyorJogONS(CLK := HMIData.externalExitConveyorJog);

oRunExternalExitConveyor := collisionDetection.runExternalExitConveyor OR externalExitConveyorRun.Q OR (printAndApply.runConveyorAfterApply AND NOT collisionDetection.inhibitExternalExitConveyor AND HMIData.externalExitConveyorSelection <> ExteralConveyorSelection.NotInstalled) AND NOT barcodeVerificationFailed.active;
//oRunExternalExitConveyor := collisionDetection.runExternalExitConveyor OR externalExitConveyorRun.Q OR printAndApply.runConveyorAfterApply AND NOT collisionDetection.inhibitExternalExitConveyor AND HMIData.externalExitConveyorSelection <> ExteralConveyorSelection.NotInstalled;	  
	  
IF printAndApply.inhibitConveyor THEN
	exitConveyorRun.ManualOFf();
	externalExitConveyorRun.ManualOFf();
END_IF	 
		  
bagOpenFingers(enable := HMIData.bofSelection <> BagOpenFingersSelection.NotInstalled,
				releaseOutput => oBOFUp,
		 		grabOutput => oBOFDown,
				rightFingerBagPresent := iRightFingerBagPresent,
				leftFingerBagPreset := iLeftFingerBagPresent,
				bagFailedToGrabBothFingersCount := Globals.bagFailedToGrabBothFingersCount,
				bagFailedToGrabLeftFingerCount := Globals.bagFailedToGrabLeftFingerCount,
				bagFailedToGrabRightFingerCount := Globals.bagFailedToGrabRightFingerCount,
				successfulBagOpenCount := Globals.successfulBagOpenCount);

// Setup and run adjustable passthrough
//refIECObject := Pbar_ServoEIP;

IBD_Motor.Enable := HMIData.independentBagDeflatorSelection = BagDeflatorSelection.MotorizedIBD;	 
IBDMotor(ptrEIPInputs := ADR(iIBDMotorEIP),
                ptrEIPOutputs := ADR(oIBDMotorEIP),
                stepsPerInchSetpoint := Globals.STEPS_PER_INCH_TFBelt,
				reversePolarity := FALSE,
				defaultCurrentSetpoint := 650,
				commFail := IBD_Motor.eState <> IoDrvEthernetIP.AdapterState.RUNNING AND IBD_Motor.Enable,
				isHomable := TRUE);
IBDMotor.Execute();

// Clamp maximim IBD open position - 9" for Pro 18, 12" for Pro 24
IF HMIData.passthroughSetting + HMIData.IBDOffset > Globals.maximumPassthough THEN
	 IBDOutSetting := Globals.maximumPassthough;
ELSE
	IBDOutSetting := HMIData.passthroughSetting + HMIData.IBDOffset;
END_IF
		  
IBD(
	enable:= , 
	pbarOutSetting:= IBDOutSetting, 
	inPositionSetting:= HMIData.IBDClosePosition, 
	disableFaults:= , 
	extendCommand:= HMIData.IBDService.extendCommand, 
	retractCommand:= HMIData.IBDService.retractCommand ,  
	failToOpen=> , 
	state=> , 
	actualPosition=> , 
	IBDOpen=> , 
	homeRequired=> , 
	clamped=> , 
	IBDMotor:= IBDMotor);

obstructionFaultONS(CLK := (pressureBar.faults.obstructionDetected.active OR pressureBar.faults.failedToClose.active));
IF obstructionFaultONS.OSR THEN
	IBD.RemovePower();
END_IF
		 
IF HMIData.IBDService.extendCommand THEN
	HMIData.IBDService.extendCommand := FALSE;
END_IF
	 
IF HMIData.IBDService.retractCommand THEN
	HMIData.IBDService.retractCommand := FALSE;
END_IF
{endregion}
	 
hmiLight(lightOutput => oHMILight);
faultONS(CLK := HMIData.faultActive);

readyToRun := (motorizedSealFlatteners.Ready OR NOT motorizedSealFlatteners.enable) 
                AND (pressureBar.Ready OR NOT pressureBar.enable)
				AND (IBD.Ready OR NOT enableIBDDeflate)
                AND (bagDelivery.Ready OR NOT bagDelivery.enable)
                AND (zebraPrinter.Ready OR NOT zebraPrinter.enable)
				AND murrIOBusNode.ok;	

iPowerOffButtonONS(CLK := iPowerOffButton);
resetTimer(IN := iPowerOffButtonONS.OSR);

allMotorCommsGood := NOT motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.faults.commFail.active
					AND NOT IBDMotor.faults.commFail.active
					AND NOT pressureBarMotor.faults.commFail.active
					AND NOT bagDelivery._bagFeedFrontMotor.faults.commFail.active
					AND NOT bagDelivery._bagFeedRearMotor.faults.commFail.active;

IF iPowerOffButtonONS.OSR THEN
	reset();
END_IF
			
IF HMIData.makeReady OR resetTimer.Q THEN
	Cube67_BN_E_V2.xAcknowledge := TRUE;
	FestoManifold.xAcknowledge := TRUE;
	MSFMotor.xAcknowledge := TRUE;
	Bag_Delivery_EIP_Motor.xAcknowledge := TRUE;
	Pbar_ServoEIP.xAcknowledge := TRUE;
	Bag_Delivery_Rear_Motor.xAcknowledge := TRUE;
	Keyence_BCV.xAcknowledge := TRUE;
	IBD_MOtor.xAcknowledge := TRUE;
	Panther_PA.xAcknowledge := TRUE;
	
	HMIData.ackAllFaults := TRUE;
	enable := TRUE;
	
	printAndApply.Reset();
	
	bagDropTimer.IN := FALSE;
	
	motorizedSealFlattenersMode := DEVICE_MODES.Auto;
	motorizedSealFlatteners.Reset();
	
	HMIData.bagOpenFeedNewBagCount := 0;
	bagOpenRetryCount := 0;
	
	HMIData.stopMachine := FALSE;
	HMIData.inCycle := FALSE;
	electricPressureBarMode := DEVICE_MODES.Auto;
	
	pressureBar.enable := TRUE;
	enableHeater := TRUE;
	
	bagDeliveryMode := DEVICE_MODES.Auto;
	bagDelivery.Reset();
	bagDelivery.enable := TRUE;
	
	IF NOT bagOpenFingers.CheckIfBagGrabbed(FALSE) THEN
		bagOpened := FALSE;
	END_IF

	printerMode := DEVICE_MODES.Auto;
	zebraPrinter.Reset();
	
	IF iPowerOffButtonONS.OSR AND NOT bagDelivery.bagTensionFault.active THEN
		IF (HMIData.factoryTestMode AND (HMIData.bagsMade.count < 1000)) THEN
			HMIData.bagsMade.Clear();
		END_IF 
	END_IF  
	
	pressureBarMotor.Reset();
	passthroughMode := DEVICE_MODES.Auto;

	oVacOn := FALSE;
	rearLoadPlate.Reset();
	frontLoadPlate.Reset();
	loadShelf.Reset();
	collisionDetection.Reset();
	
	LPA.Reset();
	LPA.ManualOff();
	HPA.Reset();
	IF (HMIData.funnelFactorySelection = FunnelSelection.BagLoadingTray) THEN
		IF pressureBar.pressureBarOpen THEN
			funnel.Open();
		ELSE
			funnel.Close();
		END_IF
	ELSE
		funnel.Close();
	END_IF
	
	exitConveyorRun.Reset();
	externalExitConveyorRun.Reset();
	oSealBarExtend := FALSE;
	oSealBarRetract := TRUE;
	sealTimer.IN := FALSE;
	pressureBarCloseDelay.IN := FALSE;
	filler.Reset();
	_auxIOManager.Reset();
	fillerModeCycleStartOnlyPulse.Reset();
	barcodeVerifier.Reset();
	keyenceBCV.Reset();
	state.head := HEAD_STATES.Idle;
	setPassthroughPB := FALSE;
	HMIData.jobLoadRequired.active := TRUE;
	HMIData.makeReady := FALSE;
	hmiLight.TurnOff();
	autoModeKeepCycling := FALSE;
	
ELSE
	Cube67_BN_E_V2.xAcknowledge := FALSE;
	FestoManifold.xAcknowledge := FALSE;
	MSFMotor.xAcknowledge := FALSE;
	Bag_Delivery_EIP_Motor.xAcknowledge := FALSE;
	Pbar_ServoEIP.xAcknowledge := FALSE;
	Bag_Delivery_Rear_Motor.xAcknowledge := FALSE;
	Keyence_BCV.xAcknowledge := FALSE;
	IBD_MOtor.xAcknowledge := FALSE;
	Panther_PA.xAcknowledge := FALSE;
END_IF

IF enableONS.Q OR resetONS.Q THEN
    state.head := HEAD_STATES.Idle;
	state.sb.sealSeparate := SEAL_SEPARATE_STATES.Idle;
	state.sb.releaseFeed := RELEASE_FEED_STATES.Idle;
	state.sb.openBag := BAG_OPEN_ASSIST_STATES.Idle;
	state.sb.finishCycle := FINISH_CYCLE_STATES.Idle;
	state.sb.automation := AUTOMATION_STATES.Idle;
	state.sb.printOutOfCycle := PRINT_OUT_OF_CYCLE_STATES.Idle;
	motorizedSealFlatteners.Reset();
	pressureBar.Reset();
	IBD.Reset();
	bagDelivery._bagFeedRearMotor.EnableTensionFault();
	bagDelivery.AutoFeedToEye();
// 	bagDelivery.Reset();
	zebraPrinter.Reset();
	homeJawPB := FALSE;

	IF IBD.homeRequired THEN
		homeJawPB := TRUE;
	ELSE
		homeJawPB := TRUE;
	END_IF
	IF pressureBar.homeRequired THEN
		homeJawPB := TRUE;
	ELSE
		homeJawPB := TRUE;
	END_IF

	bagDropTimer.IN := FALSE;
	_reset := FALSE;
	cycleTimer.IN := FALSE;
END_IF

IF HMIData.bagsMade.count >= 1000 THEN
	Globals.factoryTestComplete := TRUE;
END_IF

IF Globals.factoryTestComplete THEN
	HMIData.machineNotTested.active := FALSE;
ELSE
	HMIData.machineNotTested.active := TRUE;
END_IF

IF HMIData.factoryTestMode THEN
	HMIData.factoryTestModeActive.active := TRUE;
ELSE
	HMIData.factoryTestModeActive.active := FALSE;
END_IF

// Disable the printer on dry cycle because we dont't want to print on the platen roller               
IF HMIData.enableDryCycle THEN
    zebraPrinter.enable := FALSE;
END_IF

// Send torque value to motor                 
rearMotorCommsReturned(CLK := bagDelivery._bagFeedRearMotor.commFail);
IF HMIData.jobLoaded OR rearMotorCommsReturned.Q THEN
	bagDelivery._bagFeedRearMotor.SetTorque((TO_DINT(HMIData.bagTensionSetting * 100)));
END_IF

// Clear batch count on batch enable
batchEnableONS(CLK := HMIData.batchEnable);
IF (batchEnableONS.OSR)
	OR (NOT HMIData.batchEnable) 
	OR (HMIData.batchReset)
	OR (resetONS.Q AND HMIData.batchCountDone.active)
THEN
    HMIData.batchCount := 0;
	HMIData.batchReset := FALSE;
END_IF
HMIData.batchCountDone.active := (HMIData.batchCount >= HMIData.batchSetting) AND HMIData.batchEnable;
IF HMIData.batchCountDone.active OR NOT HMIData.autoEnable OR HMIData.fillerEnable THEN
	autoModeKeepCycling := FALSE;
END_IF

//IF NOT enable OR NOT readyToRun OR faultONS.OSR THEN
IF NOT enable OR faultONS.OSR THEN
	state.head := HEAD_STATES.Fault;
	//pressureBarMotor.Stop();
	cycleTimer.IN := FALSE;
END_IF
pressureBarCloseDelay(PT := TO_TIME(HMIData.pressureBarCloseDelay * 1000));
cycleTimer();
autoModeKeepCyclingTimer(PT := TO_TIME(HMIData.autoModeDwell * 1000), IN := autoModeKeepCycling AND state.head = HEAD_STATES.Idle);

HMIData.mayCycleUnexpectedly.active := autoModeSelected OR filler.activateFiller;

footSwitchONS(CLK := iFootSwitch);
_bagGrabbedONS(CLK := _auxIOManager.bagGrabbed OR _auxIORemote.bagGrabbed);

IF state.head <> HEAD_STATES.Idle AND HMIData.initiateCycle THEN
	HMIData.initiateCycle := FALSE;
END_IF
CASE state.head OF
    HEAD_STATES.Idle :                              // Start cycle if enabled
                                                    IF (startCycle AND (filler.cycleBaggerToActivateFiller.active OR NOT filler.activateFiller)
													OR (HMIData.factoryTestMode AND (HMIData.bagsMade.count < 1000)) AND (factoryTestModeKeepCycling AND NOT LPA.Q)
													OR (startCycleReqFromPalmButtonsONS.OSR) AND (filler.cycleBaggerToActivateFiller.active OR NOT filler.activateFiller)
													OR (HMIData.initiateCycle) AND (filler.cycleBaggerToActivateFiller.active OR NOT filler.activateFiller)
													OR (filler.cycleBagRequest AND HMIData.autoEnable)
													OR (filler.cycleBagRequest AND NOT HMIData.autoEnable) AND (footSwitchONS.OSR OR HMIData.initiateCycle OR startCycleReqFromPalmButtonsONS.OSR)
													OR (autoModeKeepCyclingTimer.Q)
													OR footSwitchONS.OSR AND (filler.cycleBaggerToActivateFiller.active OR NOT filler.activateFiller))
													AND (NOT HMIData.sealBarNotAtTemperature.active OR HMIData.enableDryCycle)
													AND NOT barcodeVerificationFailed.active
													AND NOT HMIData.faultActive 
													AND NOT HMIData.stopMachine 
													AND NOT HMIData.baggerInhibited.active
													AND NOT HMIData.batchCountDone.active
													AND NOT setPassthroughPB
													AND NOT printAndApply.clearOutBaggerIndicaiton
													AND readyToRun THEN
                                                        startCycle := FALSE;
														cycleTimer.IN := TRUE;
														HMIData.initiateCycle := FALSE;
														state.head := HEAD_STATES.SealAndSeparateBag;
														IF bagOpenFingers.CheckIfBagGrabbed(FALSE) THEN
															bagOpened := TRUE;
														END_IF
                                                    END_IF
													
													IF HMIData.baggerProfileSelection = BaggerProfile.EQ22085 THEN
														IF _bagGrabbedONS.Q THEN
															state.head := HEAD_STATES.PrepareForAutomatedBagRemoval;
														END_IF
                                                    END_IF
													IF NOT Globals.passthroughChangedFromJog AND HMIData.jobLoaded THEN
														HMIData.jobLoaded := FALSE;
													END_IF
                                                    IF (TO_DINT(HMIData.passthroughSetting*1000) <> TO_DINT(passthroughSettingLast*1000)) OR (Globals.passthroughChangedFromJog AND HMIData.jobLoaded) AND NOT pressureBarMotor.Faulted AND NOT pressureBarMotor.HomeRequired THEN
															setPassthroughPB := TRUE;
															Globals.passthroughChangedFromJog := FALSE;
															HMIData.jobLoaded := FALSE;
															passthroughSetting := HMIData.passthroughSetting;
															passthroughSettingLast := HMIData.passthroughSetting;
													END_IF
													
													IF (NOT (pressureBarMotor.HomeRequired OR pressureBarMotor.Faulted))
														AND ((NOT motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.homeRequiredIndication OR motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.Faulted) OR NOT motorizedSealFlatteners.enable)
														AND readyToRun 
														AND NOT HMIData.faultActive
													THEN
														hmiLight.TurnOn();
													END_IF
													
													IF HMIData.stopMachine THEN
														setPassthroughPB := FALSE;
														homeJawPB := FALSE;
														startCycle := FALSE;
														HMIData.initiateCycle := FALSE;
														factoryTestModeKeepCycling := FALSE;
														autoModeKeepCycling := FALSE;
														hmiLight.TurnOff();
														filler.Reset();
														ezFeed.Reset();
														LPA.Reset();
													END_IF
													
													IF HMIData.sealBarNotAtTemperature.active THEN
														factoryTestModeKeepCycling := FALSE;
														autoModeKeepCycling := FALSE;
													END_IF
													
													IF bagOpened THEN
                                                        IF NOT bagOpenFingers.CheckIfBagGrabbed(FALSE) AND NOT HMIData.enableDryCycle THEN
															openedBagWasRemoved.Trigger();
															bagOpened := FALSE;
														END_IF
													END_IF
													
													{region:'Service'}
													IF setPassthroughPB AND NOT homeJawPB THEN
														hmiLight.BlinkSlow();
														IF HMIData.passthroughPosition < HMIData.passthroughSetting THEN
															motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.MoveToPositionTorque(2,1000,1000,2000,125);
														END_IF
														state.head := HEAD_STATES.MovePassthrough;
													END_IF
														
													IF homeJawPB THEN
														hmiLight.BlinkSlow();
														state.head := HEAD_STATES.StartHoming;
													END_IF    
													
													IF HMIData.loadPlateService.retractCommand OR HMIData.rearLoadPlateService.retractCommand THEN
														rearLoadPlate.ManualOn();
														HMIData.loadPlateService.retractCommand := FALSE;
														HMIData.rearLoadPlateService.retractCommand := FALSE;
													END_IF                                      
                                                    
													IF HMIData.loadPlateService.extendCommand OR HMIData.rearLoadPlateService.extendCommand THEN
														rearLoadPlate.ManualOff();
														HMIData.loadPlateService.extendCommand := FALSE;
														HMIData.rearLoadPlateService.extendCommand := FALSE;
													END_IF
													
													IF HMIData.loadShelfService.retractCommand THEN
														loadShelf.ManualOn();
														HMIData.loadShelfService.retractCommand := FALSE;
													END_IF                                      
                                                    
													IF HMIData.loadShelfService.extendCommand THEN
														loadShelf.ManualOff();
														HMIData.loadShelfService.extendCommand := FALSE;
													END_IF	

													IF HMIData.forwardLoadPlateService.retractCommand THEN
														frontLoadPlate.ManualOn();
														HMIData.forwardLoadPlateService.retractCommand := FALSE;
													END_IF                                      
                                                    
													IF HMIData.forwardLoadPlateService.extendCommand THEN
														frontLoadPlate.ManualOff();
														HMIData.forwardLoadPlateService.extendCommand := FALSE;
													END_IF	 
													
													IF HMIData.IBDService.retractCommand THEN
														IBD.CloseIBD();
														HMIData.IBDService.retractCommand := FALSE;
													END_IF                                      
                                                    
													IF HMIData.IBDService.extendCommand THEN
														IBD.OpenIBD();
														HMIData.IBDService.extendCommand := FALSE;
													END_IF	
														 
													IF HMIData.funnelService.retractCommand THEN
														funnel.Open();
														HMIData.funnelService.retractCommand := FALSE;
													END_IF                                      
                                                    
													IF HMIData.funnelService.extendCommand THEN
														funnel.Close();
														HMIData.funnelService.extendCommand := FALSE;
													END_IF	
	 													
													IF HMIData.pressureBarService.extendCommand THEN
														pressureBar.OpenJaw();
														HMIData.pressureBarService.extendCommand := FALSE;
													END_IF	
														 
													IF HMIData.pressureBarService.retractCommand THEN
														pressureBar.CloseJaw();
														HMIData.pressureBarService.retractCommand := FALSE;
													END_IF	
														 
													IF HMIData.lpaServicePulse THEN
														LPA.DwellSetting := TO_DINT(HMIData.lpaDwell * 1000);
														LPA.Trigger();
														HMIData.lpaServicePulse := FALSE;
													ELSIF HMIData.lpaServiceOn THEN
														LPA.ManualOn();
														HMIData.lpaServiceOn := FALSE;
													ELSIF HMIData.lpaServiceOff THEN
														LPA.ManualOff();
														HMIData.lpaServiceOff := FALSE;
													END_IF
													
													IF HMIData.vacuumServiceOn THEN
														oVacOn := TRUE;
														HMIData.vacuumServiceOn := FALSE;
													ELSIF HMIData.vacuumServiceOff THEN
														oVacOn := FALSE;
														HMIData.vacuumServiceOff := FALSE;
													END_IF
														 		  
													IF HMIData.hpaServicePulse THEN
														hpa.Trigger();
														HMIData.hpaServicePulse := FALSE;
													ELSIF hpaServiceOnONS.OSR THEN
														HPA.ManualOn();
													ELSIF hpaServiceOnONS.OSF THEN
														HPA.ManualOff();
													END_IF
													
													IF HMIData.exitConveyorStartDwell THEN
														exitConveyorRun.Trigger();
														HMIData.exitConveyorStartDwell := FALSE;
													ELSIF HMIData.exitConveyorStart OR exitConveyorJogONS.OSR THEN
														exitConveyorRun.ManualOn();
														HMIData.exitConveyorStart := FALSE;
													ELSIF HMIData.exitConveyorStop OR exitConveyorJogONS.OSF THEN
														exitConveyorRun.ManualOff();
														HMIData.exitConveyorStop := FALSE;
													END_IF
													
													IF HMIData.externalExitConveyorStartDwell THEN
														externalExitConveyorRun.Trigger();
														HMIData.externalExitConveyorStartDwell := FALSE;
													ELSIF HMIData.externalExitConveyorStart OR externalExitConveyorJogONS.OSR THEN
														externalExitConveyorRun.ManualOn();
														HMIData.externalExitConveyorStart := FALSE;
													ELSIF HMIData.externalExitConveyorStop OR externalExitConveyorJogONS.OSF THEN
														externalExitConveyorRun.ManualOff();
														HMIData.externalExitConveyorStop := FALSE;
													END_IF
	 
													IF HMIData.sealBarServiceCycle THEN
														sealTimer.PT := TO_TIME(HMIData.sealBarDwell * 1000);
														sealTimer.IN := TRUE;
														IF NOT sealTimer.Q THEN
															oSealBarExtend := TRUE;
															oSealBarRetract := FALSE;
														ELSE 
															sealTimer.IN := FALSE;
															oSealBarExtend := FALSE;
															oSealBarRetract := TRUE;
															HMIData.sealBarCycles.Increment();
															HMIData.sealBarServiceCycle := FALSE;
														END_IF
													ELSIF HMIData.sealBarServiceExtend THEN
														oSealBarExtend := TRUE;
														oSealBarRetract := FALSE;
														HMIData.sealBarServiceExtend := FALSE;
													ELSIF HMIData.sealBarServiceRetract THEN
														oSealBarExtend := FALSE;
														oSealBarRetract := TRUE;
														HMIData.sealBarServiceRetract := FALSE;
													END_IF
														 
													IF HMIData.bagOpenFingersServiceGrab THEN
														bagOpenFingers.Grab();
														HMIData.bagOpenFingersServiceGrab := FALSE;
													ELSIF HMIData.bagOpenFingersServiceRelease THEN
														bagOpenFingers.Release();
														HMIData.bagOpenFingersServiceRelease := FALSE;
													END_IF
													{endregion:'Service'}
                                                    
													                                                         
                                                    // Fault if labels stack up in queue 
                                                    IF (printerDataReady AND HmiData.labelsQueuedUpFaultEnable) THEN
                                                        labelsQueuedUpFault.faultTrigger := TRUE;    
                                                    ELSE
                                                        labelsQueuedUpFault.faultTrigger := FALSE;
                                                    END_IF              
														 
    HEAD_STATES.SealAndSeparateBag :                // Begin Seal and Separate State machine
		// Begin Seal and Separate State machine
													IF printAndApply.enable AND bagOpened THEN
														printAndApply.BeginCycle();
													END_IF
													filler.BaggerCycleInitiated();
                                                    HMIData.inCycle := TRUE;
													HMIData.airFilterClean.Increment();
													HMIData.baggerCycles.Increment();
													IF funnel.enable THEN
														funnel.Close();
													END_IF
													
        											state.head := HEAD_STATES.SealingAndSeparatingBag;
													state.sb.sealSeparate := SEAL_SEPARATE_STATES.Shake;
                                                    
    HEAD_STATES.SealingAndSeparatingBag :            IF state.sb.sealSeparate = SEAL_SEPARATE_STATES.Done THEN
                                                        state.head := HEAD_STATES.SealedAndSeparatedBag;
                                                        state.sb.sealSeparate := SEAL_SEPARATE_STATES.Idle;
                                                    END_IF    

    HEAD_STATES.SealedAndSeparatedBag :             state.head := HEAD_STATES.ReleaseAndFeedBag;                                    
                                                    
    HEAD_STATES.ReleaseAndFeedBag :                    // Open the jaw and release the bag
                                                    state.sb.releaseFeed := RELEASE_FEED_STATES.WaitForPressureBarOpenTimer;
                                                    state.head := HEAD_STATES.ReleasingAndFeedingBag;
                                                    
    HEAD_STATES.ReleasingAndFeedingBag :            // 
                                                    IF state.sb.releaseFeed = RELEASE_FEED_STATES.Done THEN
                                                       state.head := HEAD_STATES.ReleasedAndFedBag;
                                                       state.sb.releaseFeed := RELEASE_FEED_STATES.Idle;
                                                    END_IF
                                                    
    HEAD_STATES.ReleasedAndFedBag :                    // 
                                                    {warning 'TODO: change this counting logic to account for MSF'}
                                                    IF HMIData.batchEnable THEN
                                                        HMIData.batchCount := HMIData.batchCount + 1;
                                                    END_IF
  
                                                    IF HMIData.enableDryCycle THEN
                                                        Globals.dryCycleCount := Globals.dryCycleCount + 1;     
                                                    ELSE
                                                        Globals.bagsMadeCount := Globals.bagsMadeCount + 1; 
                                                    END_IF
													IF enableBagOpen THEN
                                                    	state.head := HEAD_STATES.OpenBag;
                                                    ELSE
                                                        state.head := HEAD_STATES.FinishCycle;
                                                    END_IF
                                                                   
    HEAD_STATES.OpenBag :                            // Close jaw to grab the bag
                                                    state.sb.openBag := BAG_OPEN_ASSIST_STATES.MoveJawIn;
                                                    state.head := HEAD_STATES.OpeningBag;
                                                    
                                                    
    HEAD_STATES.OpeningBag :                        // Open jaw and grab onto the bag
                                                    IF state.sb.openBag = BAG_OPEN_ASSIST_STATES.Done THEN
                                                        state.head := HEAD_STATES.OpenedBag;
                                                        state.sb.openBag := BAG_OPEN_ASSIST_STATES.Idle;
													ELSIF state.sb.openBag = BAG_OPEN_ASSIST_STATES.FeedNewBag THEN
														state.head := HEAD_STATES.SealAndSeparateBag;
														state.sb.openBag := BAG_OPEN_ASSIST_STATES.Idle;
                                                    END_IF
                                                    
    HEAD_STATES.OpenedBag :                            // Move fingers in and to bag holding and reset cycle
                                                    IF ((motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.Idle)
														OR (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersIn AND HMIData.funnelFactorySelection = FunnelSelection.BagLoadingTray)	
														OR NOT motorizedSealFlatteners.enable)
														THEN
														state.head := HEAD_STATES.FinishCycle;
                                                    END_IF
	HEAD_STATES.FinishCycle :			//
													state.sb.finishCycle := FINISH_CYCLE_STATES.Start;
													state.head := HEAD_STATES.FinishingCycle;
	HEAD_STATES.FinishingCycle : 		//
													IF state.sb.finishCycle = FINISH_CYCLE_STATES.Done THEN
														state.head := HEAD_STATES.FinishedCycle;
														state.sb.finishCycle := FINISH_CYCLE_STATES.Idle;
													END_IF
	HEAD_STATES.FinishedCycle :			//
											HMIData.bagsMade.Increment();
											HMIData.resettableBagsMade.Increment();
                                            state.head := HEAD_STATES.Idle;
											filler.BaggerCycledAndReady();
											cycleTime := (TIME_TO_REAL(cycleTimer.ET) / 1000); 
											cycleTimer.IN := FALSE;
											IF HMIData.averageCycleTime = 0 THEN
												HMIData.averageCycleTime := cycleTime;
											ELSE
												HMIData.averageCycleTime := (cycleTime + HMIData.averageCycleTime) / 2;
											END_IF
											HMIData.inCycle := FALSE;
											
											IF HMIData.autoEnable AND NOT HMIData.stopMachine AND NOT HMIData.fillerEnable THEN
												autoModeKeepCycling := TRUE;
											END_IF								
											
											IF HMIData.factoryTestMode AND NOT HMIData.stopMachine THEN
												IF (HMIData.bagsMade.count >= 1000) THEN
													factoryTestModeKeepCycling := FALSE;
													HMIData.factoryTestMode := FALSE;
												ELSE
													factoryTestModeKeepCycling := TRUE;
												END_IF
											END_IF		
		
    HEAD_STATES.StartHoming :            // 
											IF allMotorCommsGood THEN
												motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.faults.notHomed.Ack();
												IF pressureBar.homeRequired THEN
													pressureBar.HomeNow();
												ELSE
													pressureBar.OpenJaw();
												END_IF
												IF IBD.homeRequired THEN
													IF NOT frontLoadPlate.enable THEN
														rearLoadPlate.ManualOn();
													END_IF
													IBD.HomeNow();
												ELSE
													IBD.OpenIBD();
												END_IF
                                            	state.head := HEAD_STATES.Homing; 
											END_IF                             
    
    HEAD_STATES.Homing :                // 
											IF pressureBar.pressureBarOpen AND (NOT IBD.Ready OR NOT IBD.enable) THEN
                                                state.head := HEAD_STATES.HomingComplete;
												
												//
												IF loadShelf.inUse OR loadShelf.LoadingPositionWhileDisabled THEN
													loadShelf.ManualOff();
												END_IF
												
												//
												IF rearLoadPlate.inUse OR rearLoadPlate.LoadingPositionWhileDisabled THEN
													IF rearLoadPlate.inDischargePosition THEN
														rearLoadPlate.ManualOff();
													END_IF
												END_IF
												
												//
												IF loadShelf.inUse OR loadShelf.LoadingPositionWhileDisabled THEN
													IF loadShelf.inDischargePosition THEN
														loadShelf.ManualOff();
													END_IF
												END_IF
												
												IF motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.HomeRequired AND motorizedSealFlatteners.enable THEN
													motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.HomeNow();
													motorizedSealFlatteners.sealFlattenersVerticalAxis.Retract();
												END_IF    
                                            END_IF
                                            
    HEAD_STATES.HomingComplete :            // 
											IF (NOT motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.HomeRequired) OR NOT motorizedSealFlatteners.enable THEN
												homeJawPB := FALSE;
												motorizedSealFlatteners.sealFlattenersVerticalAxis.Extend();
												state.head := HEAD_STATES.MovePassthrough;
											END_IF
                                           
    HEAD_STATES.MovePassthrough :           // 
                                            pressureBar.OpenJaw();
											IBD.OpenIBD();
                                            state.head := HEAD_STATES.MovingPassthrough;
    
    HEAD_STATES.MovingPassthrough :    		IF pressureBar.pressureBarOpen AND (IBD.IBDOpen OR HMIData.independentBagDeflatorSelection = BagDeflatorSelection.NotInstalled) THEN
                                                state.head := HEAD_STATES.MovedPassthrough;     
                                            END_IF
                                            
    HEAD_STATES.MovedPassthrough :          // 
                                            state.head := HEAD_STATES.Idle;
											setPassthroughPB := FALSE;
											motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.MoveToPositionTorque(HMIData.bagWidth,1000,1000,1000,125);
                                                    
	HEAD_STATES.PrepareForAutomatedBagRemoval:
		//
		state.head := HEAD_STATES.PreparingForAutomatedBagRemoval;
		state.sb.automation := AUTOMATION_STATES.MoveSealFlattenersUp;
		
	HEAD_STATES.PreparingForAutomatedBagRemoval:
		//
		IF state.sb.automation = AUTOMATION_STATES.Done THEN
			_auxIOManager.ResetReadyForGrab();
			_auxIORemote.ResetReadyForGrab();
			state.head := HEAD_STATES.PreparedForAutomatedBagRemoval;
		END_IF
	
	HEAD_STATES.PreparedForAutomatedBagRemoval:
		//
		state.head := HEAD_STATES.Idle;
		state.sb.automation := AUTOMATION_STATES.Idle;
                                                    
    HEAD_STATES.Fault :                     hmiLight.TurnOff();
											HMIData.inCycle := FALSE;
											cycleTimer.IN := FALSE;
											bagDelivery.PointToPointOnFault();
											state.sb.sealSeparate := SEAL_SEPARATE_STATES.Idle;
											state.sb.releaseFeed := RELEASE_FEED_STATES.Idle;
											state.sb.openBag := BAG_OPEN_ASSIST_STATES.Idle;
											state.sb.finishCycle := FINISH_CYCLE_STATES.Idle;
											oVacOn := FALSE;
											filler.Reset();
											funnel.Reset();
											LPA.ManualOff();
											exitConveyorRun.Reset();
											externalExitConveyorRun.Reset();
											oRunPrinterRibbonUnwindMotor := FALSE;
											setPassthroughPB := FALSE;
											homeJawPB := FALSE;
											startCycle := FALSE;
											HMIData.initiateCycle := FALSE;
											factoryTestModeKeepCycling := FALSE;
											autoModeKeepCycling := FALSE;
											pressureBarCloseDelay.IN := FALSE;
											oSealBarExtend := FALSE;
											oSealBarRetract := TRUE;
											
									
END_CASE

CASE state.sb.sealSeparate OF
	SEAL_SEPARATE_STATES.Shake:						
		//
		IF loadShelf.shakeStart = SHAKER_START_SELECTION.CycleStart OR
   		   loadShelf.shakeStart = SHAKER_START_SELECTION.Both THEN
		   loadShelf.Shake();
		END_IF
		
		//
		IF rearLoadPlate.shakeStart = SHAKER_START_SELECTION.CycleStart OR
   		   rearLoadPlate.shakeStart = SHAKER_START_SELECTION.Both THEN
		   rearLoadPlate.Shake();
		END_IF
		
		//
		IF frontLoadPlate.shakeStart = SHAKER_START_SELECTION.CycleStart OR
   		   frontLoadPlate.shakeStart = SHAKER_START_SELECTION.Both THEN
		   frontLoadPlate.Shake();
		END_IF

		//
		IF rearLoadPlate.Shaking OR frontLoadPlate.Shaking OR loadShelf.Shaking THEN
			state.sb.sealSeparate := SEAL_SEPARATE_STATES.Shaking;
		ELSIF enableIBDDeflate THEN
			state.sb.sealSeparate := SEAL_SEPARATE_STATES.BringInIBD;
		ELSE
			state.sb.sealSeparate := SEAL_SEPARATE_STATES.WaitForJawCloseDelay;
		END_IF
													
	SEAL_SEPARATE_STATES.Shaking:				    //
		IF NOT frontLoadPlate.Shaking AND NOT rearLoadPlate.Shaking AND NOT loadShelf.Shaking THEN
			state.sb.sealSeparate := SEAL_SEPARATE_STATES.PrepareToFeedToSeal;
		END_IF
		
	SEAL_SEPARATE_STATES.PrepareToFeedToSeal:
		IF HMIData.feedToSealInUse THEN
			IF enableBagOpen THEN
				bagOpenFingers.Release();
			END_IF
			motorizedSealFlatteners.AutoMovetoFeedToSeal();
			state.sb.sealSeparate := SEAL_SEPARATE_STATES.PreparingToFeedToSeal;	
		ELSE
			//
			IF enableIBDDeflate THEN
				state.sb.sealSeparate := SEAL_SEPARATE_STATES.BringInIBD;
			ELSE
				state.sb.sealSeparate := SEAL_SEPARATE_STATES.WaitForJawCloseDelay;
			END_IF	
		END_IF
	
	SEAL_SEPARATE_STATES.PreparingToFeedToSeal:
		IF motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.Idle THEN
			state.sb.sealSeparate := SEAL_SEPARATE_STATES.PreparedToFeedToSeal;
		END_IF
	
	SEAL_SEPARATE_STATES.PreparedToFeedToSeal:
		state.sb.sealSeparate := SEAL_SEPARATE_STATES.FeedToSeal;

	SEAL_SEPARATE_STATES.FeedToSeal:
		IF HMIData.feedToSealInUse THEN
			bagDelivery.AutoFeedToSeal();
			state.sb.sealSeparate := SEAL_SEPARATE_STATES.FeedingToSeal;		
		ELSE
			//
			IF enableIBDDeflate THEN
				state.sb.sealSeparate := SEAL_SEPARATE_STATES.BringInIBD;
			ELSE
				state.sb.sealSeparate := SEAL_SEPARATE_STATES.WaitForJawCloseDelay;
			END_IF
		END_IF
	SEAL_SEPARATE_STATES.FeedingToSeal:
		//
		IF bagDelivery.state = BAG_DELIVERY_STATES.Ready THEN
			state.sb.sealSeparate := SEAL_SEPARATE_STATES.FedToSeal;
		END_IF
	
	SEAL_SEPARATE_STATES.FedToSeal:
		//
		// motorizedSealFlatteners.AutoEnableMotion();
		IF enableIBDDeflate THEN
			state.sb.sealSeparate := SEAL_SEPARATE_STATES.BringInIBD;
		ELSE
			state.sb.sealSeparate := SEAL_SEPARATE_STATES.WaitForJawCloseDelay;
		END_IF											
 
	SEAL_SEPARATE_STATES.BringInIBD: 				// Bring in IBD if enabled
													IF enableIBDDeflate THEN
														IBD.CloseIBD();
													END_IF 
													state.sb.sealSeparate := SEAL_SEPARATE_STATES.WaitForJawCloseDelay;
	
	SEAL_SEPARATE_STATES.WaitForJawCloseDelay: 	    // Wait for jaw close delay. 
													IF pressureBar.enable THEN
														LPA.ManualOff();
														pressureBarCloseDelay.IN := TRUE;
														IF (pressureBarCloseDelay.Q OR HMIData.pressureBarCloseDelay = 0) 
															//AND (funnel.closed OR NOT funnel.enable)
															THEN
															state.sb.sealSeparate := SEAL_SEPARATE_STATES.MoveJawIn;
															pressureBarCloseDelay.IN := FALSE;
														END_IF
                                                    ELSE 
                                                        state.sb.sealSeparate := SEAL_SEPARATE_STATES.ReverseBag;
                                                    END_IF
        
    SEAL_SEPARATE_STATES.MoveJawIn:                 // Perform actions as enabled - close jaw and move flatteners out. If jaw is disabled then go right to reverse bag
                                                    IF motorizedSealFlatteners.enable THEN
                                                        motorizedSealFlatteners.AutoMoveOut();
                                                    END_IF
                                                
													pressureBar.CloseJaw();
                                                    state.sb.sealSeparate := SEAL_SEPARATE_STATES.MovingJawIn;
                                                    
    SEAL_SEPARATE_STATES.MovingJawIn :              // If Jaw is in and flatteners out then move on
                                                    IF (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersOut OR NOT motorizedSealFlatteners.enable) 
                                                        AND (pressureBar.clamped OR NOT pressureBar.enable)
                                                        THEN
                                                            state.sb.sealSeparate := SEAL_SEPARATE_STATES.MovedJawIn;    
                                                    END_IF
                                                                
    SEAL_SEPARATE_STATES.MovedJawIn :               // Will add sealing logic here
                                                    state.sb.sealSeparate := SEAL_SEPARATE_STATES.ReverseBag;
                                                    
    SEAL_SEPARATE_STATES.ReverseBag :               // Reverse bag if bag delivery enabled, otherwise open jaw
													//IBD.OpenFull();
                                                    IF bagDelivery.enable THEN
                                                        bagDelivery.AutoReverseBag();
                                                        state.sb.sealSeparate := SEAL_SEPARATE_STATES.ReversingBag;
                                                    ELSE state.sb.sealSeparate := SEAL_SEPARATE_STATES.Done;    
                                                    END_IF
                                                                    
    SEAL_SEPARATE_STATES.ReversingBag :             // 
													IF NOT HMIData.separateBeforeSeal THEN
														sealTimer.PT := TO_TIME(HMIData.sealBarDwell * 1000);
														sealTimer.IN := TRUE;
														IF NOT sealTimer.Q THEN
															oSealBarExtend := TRUE;
															oSealBarRetract := FALSE;
														ELSE 
															oSealBarExtend := FALSE;
															oSealBarRetract := TRUE;
														END_IF
													END_IF

                                                    IF (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersOut OR NOT motorizedSealFlatteners.enable) 
                                                        AND (pressureBar.clamped OR NOT pressureBar.enable)
                                                        AND (bagDelivery.state = BAG_DELIVERY_STATES.ReverseDone OR NOT bagDelivery.enable)
														AND (sealTimer.Q OR HMIData.separateBeforeSeal)
                                                        THEN
															IF NOT HMIData.separateBeforeSeal THEN
																HMIData.sealBarCycles.Increment();
															END_IF
															
															sealTimer.IN := FALSE;
                                                            state.sb.sealSeparate := SEAL_SEPARATE_STATES.Reversedbag;
                                                    END_IF
													
    SEAL_SEPARATE_STATES.Reversedbag :              // 
													//Print mid cycle if needed.
													IF zebraPrinter.enable AND HMIData.printerCycleSelection = PrinterCycleSelection.PrintMidCycle THEN
														state.sb.printOutOfCycle := PRINT_OUT_OF_CYCLE_STATES.WaitForPrinter;
													END_IF
													
                                                    state.sb.sealSeparate := SEAL_SEPARATE_STATES.SealBag;
													
	SEAL_SEPARATE_STATES.SealBag:					
													IF HMIData.separateBeforeSeal THEN
														sealTimer.PT := TO_TIME(HMIData.sealBarDwell * 1000);
														sealTimer.IN := TRUE;
														IF NOT sealTimer.Q THEN
															oSealBarExtend := TRUE;
															oSealBarRetract := FALSE;
														ELSE 
															sealTimer.IN := FALSE;
															oSealBarExtend := FALSE;
															oSealBarRetract := TRUE;
															HMIData.sealBarCycles.Increment();
															state.sb.sealSeparate := SEAL_SEPARATE_STATES.Done;
														END_IF
													ELSE
														state.sb.sealSeparate := SEAL_SEPARATE_STATES.Done;
													END_IF                      
    SEAL_SEPARATE_STATES.Done:                        //
    SEAL_SEPARATE_STATES.Fault:						//
END_CASE

_waitForPressureBarOpenDelay(IN := state.sb.releaseFeed = RELEASE_FEED_STATES.WaitForPressureBarOpenTimer, PT := TO_TIME((HMIData.pressureBarOpenDelay * 1000.0)));

CASE state.sb.releaseFeed OF
    RELEASE_FEED_STATES.Idle :  
                      //
    
	RELEASE_FEED_STATES.WaitForPressureBarOpenTimer : 		// Adding in Jaw Open Delay
													IF _waitForPressureBarOpenDelay.Q THEN
														state.sb.releaseFeed := RELEASE_FEED_STATES.MoveJawOutAndDropBag;
													END_IF
													

                                                   
    RELEASE_FEED_STATES.MoveJawOutAndDropBag :        // 
                                                    IF (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersOut OR NOT motorizedSealFlatteners.enable) 
                                                        AND (pressureBar.clamped OR NOT pressureBar.enable)
                                                        AND ((bagDelivery.state = BAG_DELIVERY_STATES.ReverseDone) OR HMIData.enableDryCycle)
                                                        OR (bagDelivery.state =  BAG_DELIVERY_STATES.WaitingForPrinter AND zebraPrinter.enable)
                                                        OR NOT bagDelivery.enable
                                                        THEN
                                                            IF motorizedSealFlatteners.enable THEN
                                                                motorizedSealFlatteners.AutoMoveToClearance();
                                                            END_IF
                                                            
                                                            IF enableBagOpen THEN
                                                                pressureBar.OpenJawForBagFeed();
															ELSE
																pressureBar.OpenJaw();
                                                            END_IF
															
                                                            //IBD.OpenFull();
// 															IF enableBagOpen THEN
// 																bagOpenFingers.Release();
// 															END_IF
															
															IF enableIBDEject THEN
																IBD.CloseIBD();
															END_IF
															
															IF rearLoadPlate.enable THEN
																rearLoadPlate.Trigger();
															END_IF
															
															IF frontLoadPlate.enable THEN
																frontLoadPlate.Trigger();
															END_IF
															
															IF loadShelf.enable THEN
																loadShelf.Trigger();
															END_IF
														
															IF TO_DINT(HMIData.exitConveyorDwell) <> 0 THEN
																exitConveyorRun.Trigger();
															END_IF
															
															IF TO_DINT(HMIData.externalExitConveyorDwell) <> 0 AND NOT printAndApply.enable THEN
																externalExitConveyorRun.Trigger();
															END_IF
															
															IF HMIData.lpaBagEjectAssistEnable THEN
																LPA.ManualOn();
															END_IF
															IBD.OpenFull();
                                                           bagDropTimer.IN := TRUE;
														   state.sb.releaseFeed := RELEASE_FEED_STATES.MovingJawOutAndDroppingBag;
                                                    END_IF
													
	 RELEASE_FEED_STATES.MovingJawOutAndDroppingBag :
														// If printer is enabled then perform printer operation of bag delivery, otherwise just feed new bag out.
                                                        // In the case that bagDelivery is disabled then we're done with release and feed
														IF enableBagOpen AND pressureBar.actualPosition >= 0.5 THEN
 															bagOpenFingers.Release();
 														END_IF	
														
                                                        IF bagDropTimer.Q 
															AND (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersToBagFeed OR NOT motorizedSealFlatteners.enable)
															THEN   
															bagDropTimer.IN := FALSE;
															
															IF bagDelivery.enable AND NOT (zebraPrinter.enable AND HMIData.printerCycleSelection = PrinterCycleSelection.PrintWhileFeeding) THEN
                                                                bagDelivery.AutoFeedBagOut();
 																LPA.ManualOff();
                                                                state.sb.releaseFeed := RELEASE_FEED_STATES.MovingJawOutAndFeedingBag;
                                                            ELSIF (bagDelivery.enable AND zebraPrinter.enable AND HMIData.printerCycleSelection = PrinterCycleSelection.PrintWhileFeeding) THEN
                                                                bagDelivery.AutoWaitForPrinter();
																LPA.ManualOff();
                                                                state.sb.releaseFeed := RELEASE_FEED_STATES.WaitForPrinter;
                                                            ELSE 
                                                                state.sb.releaseFeed := RELEASE_FEED_STATES.Done;
                                                            END_IF												
    													END_IF
														
    RELEASE_FEED_STATES.WaitForPrinter :            // Data Ready means the printer has a label and we're all set to print
                                                    IF zebraPrinter.state = PRINTER_STATES.DataReady THEN
                                                        IF HMIData.lpaDuringBagFeedEnable THEN
                                                            LPA.ManualOn();
                                                        END_IF														
                                                        state.sb.releaseFeed := RELEASE_FEED_STATES.FeedToOffset;
                                                    END_IF
													IF enableBagOpen AND pressureBar.actualPosition >= 0.5 THEN
 														bagOpenFingers.Release();
 													END_IF	
                                                    
    RELEASE_FEED_STATES.FeedToOffset :              // This starts feeding to the print offset
													IF (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersToBagFeed OR NOT motorizedSealFlatteners.enable) THEN
														bagDelivery.AutoPrinterReady();
                                                    	state.sb.releaseFeed := RELEASE_FEED_STATES.FeedingToOffset;
													END_IF
													IF enableBagOpen AND pressureBar.actualPosition >= 0.5 THEN
 														bagOpenFingers.Release();
 													END_IF	
                                                    
                                                        
    RELEASE_FEED_STATES.FeedingToOffset :            // Once offset done start printing
                                                    IF bagDelivery.state = BAG_DELIVERY_STATES.FedToPrintOffset THEN
                                                        state.sb.releaseFeed := RELEASE_FEED_STATES.StartPrinting;
                                                    END_IF       
													IF enableBagOpen AND pressureBar.actualPosition >= 0.5 THEN
 														bagOpenFingers.Release();
 													END_IF	                                     
    
    RELEASE_FEED_STATES.StartPrinting :             // Printer starts print cycle and bag delivery starts moving at print speed
													zebraPrinter.AutoPrintNow();
                                                    state.sb.releaseFeed := RELEASE_FEED_STATES.SendPrintSignal;                                            

    RELEASE_FEED_STATES.SendPrintSignal:            // 
              
													IF enableBagOpen AND pressureBar.actualPosition >= 0.5 THEN
 														bagOpenFingers.Release();
 													END_IF	
													IF zebraPrinter.printHeadDebounced THEN
														bagDelivery.AutoStartPrintFeed();
														zebraPrinter.AutoSendPrintSignal();
														barcodeVerifier.Trigger();
                                                        state.sb.releaseFeed := RELEASE_FEED_STATES.Printing;
                                                    END_IF                                        

    RELEASE_FEED_STATES.Printing :                // 
													IF enableBagOpen AND pressureBar.actualPosition >= 0.5 THEN
 														bagOpenFingers.Release();
 													END_IF	
                                                    IF zebraPrinter.state = PRINTER_STATES.DonePrinting THEN
                                                        state.sb.releaseFeed := RELEASE_FEED_STATES.StopPrinting;
                                                    END_IF
                                                    
    RELEASE_FEED_STATES.StopPrinting :                // Tell bag delivery it's okay to feed out the rest of the bag and the printer that it can prep itself for the next print
                                                    bagDelivery.AutoPrinterDone();
                                                    zebraPrinter.AutoAckPrintDone();
                                                    state.sb.releaseFeed := RELEASE_FEED_STATES.MovingJawOutAndFeedingBag;
                                                                                                            
    RELEASE_FEED_STATES.MovingJawOutAndFeedingBag :    // 
													
													IF enableBagOpen AND pressureBar.actualPosition >= 0.5 THEN
 														bagOpenFingers.Release();
 													END_IF
													IF (bagDelivery.state = BAG_DELIVERY_STATES.Ready OR NOT bagDelivery.enable)
                                                        AND (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersToBagFeed OR NOT motorizedSealFlatteners.enable) 
                                                        AND (pressureBar.pressureBarOpen OR NOT pressureBar.enable)
                                                        THEN
                                                            state.sb.releaseFeed := RELEASE_FEED_STATES.MovedJawOutAndFedBag;
                                                    END_IF
                                                    
    RELEASE_FEED_STATES.MovedJawOutAndFedBag :      // Wait until bag is fed out before triggering barcode fail.
													IF barcodeVerifier.barcodeFault THEN
														barcodeVerificationFailed.Trigger();
													END_IF 
													
													// Trigger end cycle print
													IF HMIData.printerCycleSelection = PrinterCycleSelection.PrintEndCycle THEN
														state.sb.printOutOfCycle := PRINT_OUT_OF_CYCLE_STATES.WaitForPrinter;
													END_IF
													
													IF enableIBDDeflate OR enableIBDEject THEN
														IBD.OpenIBD();
													END_IF
													state.sb.releaseFeed := RELEASE_FEED_STATES.Done;
													
													IF HPA.DwellSetting <> 0 THEN
														HPA.Trigger();	
													END_IF	 
													
    RELEASE_FEED_STATES.Done :						//
    RELEASE_FEED_STATES.Fault :						//
END_CASE

CASE state.sb.openBag OF
    BAG_OPEN_ASSIST_STATES.Idle:                    // 
                                                    bagOpenCheckDelay.IN := FALSE;
                                                                         
    BAG_OPEN_ASSIST_STATES.MoveJawIn :              // Close jaw against bag. In the future we may also start vacuum here
                                                    pressureBar.CloseJawNoLatch();
												
													
													//oVacOn := TRUE; // Hard coded for now, this is vacuum
                                                    state.sb.openBag := BAG_OPEN_ASSIST_STATES.MovingJawIn;        
                                                    
    BAG_OPEN_ASSIST_STATES.MovingJawIn :            // Move on once jaw is closed
                                                    IF pressureBar.iPressureBarClosed OR NOT pressureBar.enable THEN
                                                        state.sb.openBag := BAG_OPEN_ASSIST_STATES.MovedJawIn;        
                                                    END_IF
                                                    
    BAG_OPEN_ASSIST_STATES.MovedJawIn :             // Hold onto the bag with vacuum to build suction
													IF HMIData.enableDryCycle THEN
														state.sb.openBag := BAG_OPEN_ASSIST_STATES.MoveJawOut;
													ELSE
														vacuumHoldTimer.IN := TRUE;
														oVacOn := TRUE; // Hard coded for now, this is vacuum
														IF vacuumHoldTimer.Q THEN
															vacuumHoldTimer.IN := FALSE;
															state.sb.openBag := BAG_OPEN_ASSIST_STATES.MoveJawOut;
														END_IF            
													END_IF
                                                                   
    BAG_OPEN_ASSIST_STATES.MoveJawOut :             // Open the jaw and move seal flatteners in and to bag holding
                                                    pressureBar.OpenJaw();
													motorizedSealFlatteners.AutoMoveIn();
                                                    state.sb.openBag := BAG_OPEN_ASSIST_STATES.MovingJawOutAndGrab;
                                                                                             
    BAG_OPEN_ASSIST_STATES.MovingJawOutAndGrab :    // Once everything that is enabled is homed finish cycle 
													bagOpenFingerDelay.IN := TRUE;
													IF bagOpenFingerDelay.Q THEN
														bagOpenFingers.Grab();
														bagOpenFingerDelay.IN := FALSE;
														state.sb.openBag := BAG_OPEN_ASSIST_STATES.CheckForSuccessfulBagGrab;
													END_IF
													  

	BAG_OPEN_ASSIST_STATES.CheckForSuccessfulBagGrab : 	//
														IF bagOpenRetryCount < bagOpenRetrySetting THEN
															bagOpenCheckDelay.IN := TRUE;
															IF bagOpenCheckDelay.Q THEN
																IF bagOpenFingers.CheckIfBagGrabbed(TRUE) OR HMIData.enableDryCycle THEN // This method checks to see if the bag is grabbed and returns true if so.
																	state.sb.openBag := BAG_OPEN_ASSIST_STATES.BagOpened;
																	motorizedSealFlatteners.AutoMoveIn();
																ELSE 
																	state.sb.openBag := BAG_OPEN_ASSIST_STATES.BagFailedToOpen;
																END_IF
																bagOpenCheckDelay.IN := FALSE;
															END_IF
														ELSE 
															motorizedSealFlatteners.AutoMoveToBagHolding();
															state.sb.openBag := BAG_OPEN_ASSIST_STATES.MovingJawOutAfterGrab;
														END_IF
													  
	BAG_OPEN_ASSIST_STATES.BagFailedToOpen :			// 
														bagOpenFingers.Release();
														bagOpenRetryCount := bagOpenRetryCount + 1;
														IF bagOpenRetryCount < bagOpenRetrySetting THEN
															state.sb.openBag := BAG_OPEN_ASSIST_STATES.MoveJawIn;
														ELSIF HMIData.bagOpenFeedNewBagCount < HMIData.bagOpenFeedNewBagSetting THEN
															HMIData.bagOpenFeedNewBagCount := HMIData.bagOpenFeedNewBagCount + 1;
															bagOpenRetryCount := 0;
															motorizedSealFlatteners.AutoMoveOut();
															oVacOn := FALSE;
															state.sb.openBag := BAG_OPEN_ASSIST_STATES.FeedNewBag;
															
														ELSE 
															//IF (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.Idle OR NOT motorizedSealFlatteners.enable) THEN
																motorizedSealFlatteners.AutoMoveToBagHolding();
																bagFailedToOpen.Trigger();
																
																state.sb.openBag := BAG_OPEN_ASSIST_STATES.MovingJawOutAfterGrab;
																bagOpenRetryCount := 0; 
																HMIData.bagOpenFeedNewBagCount := 0;
																HMIData.bagsRejectedTotal.Increment();
																Globals.rejectedBagCount := Globals.rejectedBagCount + 1;
															//END_IF
															
														END_IF
	
	BAG_OPEN_ASSIST_STATES.BagOpened :					//
														bagOpened := TRUE;
														// Move flatteners now if no funnel. Otherwise let the funnel move the flatteners when done
														IF NOT funnel.enable THEN 
															motorizedSealFlatteners.AutoMoveToBagHolding();
														END_IF
														
                                                    	
														bagOpenRetryCount := 0;
														HMIData.bagOpenFeedNewBagCount := 0;
														
														state.sb.openBag := BAG_OPEN_ASSIST_STATES.MovingJawOutAfterGrab; 
														  
    BAG_OPEN_ASSIST_STATES.MovingJawOutAfterGrab :		// 
														IF (pressureBar.pressureBarOpen OR NOT pressureBar.enable) 
															AND ((motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.Idle OR NOT motorizedSealFlatteners.enable)
																OR (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersIn AND HMIData.funnelFactorySelection = FunnelSelection.BagLoadingTray))
															THEN
																state.sb.openBag := BAG_OPEN_ASSIST_STATES.MovedJawOut;        
														END_IF	 
														
	BAG_OPEN_ASSIST_STATES.MovedJawOut :                // 
														oVacOn := FALSE; 		// Hard coded for now, this is vacuum
														state.sb.openBag := BAG_OPEN_ASSIST_STATES.Done;
                               
	BAG_OPEN_ASSIST_STATES.FeedNewBag :   			//
													IF (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.Idle OR NOT motorizedSealFlatteners.enable) THEN
														state.head := HEAD_STATES.SealAndSeparateBag;
													END_IF
										                        
    BAG_OPEN_ASSIST_STATES.Done:                    //                                             
    BAG_OPEN_ASSIST_STATES.Fault:                   //
													

END_CASE

CASE state.sb.finishCycle OF
	FINISH_CYCLE_STATES.Start :								//
															IF funnel.enable THEN
																state.sb.finishCycle := FINISH_CYCLE_STATES.OpenFunnel;
															ELSIF enableBagOpen THEN
																state.sb.finishCycle := FINISH_CYCLE_STATES.Shake;
															ELSE
																IF motorizedSealFlatteners.enable THEN
																	state.sb.finishCycle := FINISH_CYCLE_STATES.BringSealFlattenersInAndDown;
																ELSE
																	state.sb.finishCycle := FINISH_CYCLE_STATES.Shake;
																END_IF
															END_IF
															LPA.DwellSetting := TO_DINT(HMIData.lpaDwell * 1000);
															IF LPA.DwellSetting <> 0 THEN
																LPA.Trigger();
															END_IF
	
	FINISH_CYCLE_STATES.OpenFunnel :						//
															LPA.DwellSetting := TO_DINT(HMIData.lpaDwell * 1000);
															IF LPA.DwellSetting <> 0 THEN
																LPA.Trigger();
															END_IF
															motorizedSealFlatteners.AutoMoveToBagHolding();
															funnel.Open();
															state.sb.finishCycle := FINISH_CYCLE_STATES.OpeningFunnel;
	
	FINISH_CYCLE_STATES.OpeningFunnel :						//
															IF funnel.opened THEN
																state.sb.finishCycle := FINISH_CYCLE_STATES.OpenedFunnel;
															END_IF
	
	FINISH_CYCLE_STATES.OpenedFunnel :						//
															//IF enableBagOpen THEN
															IF iLeftFingerBagPresent AND iRightFingerBagPresent THEN
																	//IF motorizedSealFlatteners.enable THEN
																	//	state.sb.finishCycle := FINISH_CYCLE_STATES.BringSealFlattenersToBagHolding;
																	//ELSE
																		
																		state.sb.finishCycle := FINISH_CYCLE_STATES.Shake;
																	//END_IF
																	bagOpened := TRUE;
																ELSE
																	IF bagOpenRetryCount < bagOpenRetrySetting THEN
																		funnel.Close();
																		bagOpenRetryCount := bagOpenRetryCount + 1;
																		state.sb.finishCycle := FINISH_CYCLE_STATES.ClosingFunnelForRetry;
																	ELSE
																		funnel.Close();
																		bagOpenRetryCount := 0;
																		bagFailedToOpen.Trigger();
																		HMIData.bagsRejectedTotal.Increment();
																		state.sb.finishCycle := FINISH_CYCLE_STATES.Shake;
																	END_IF
																END_IF
															
																
															//END_IF
	
	FINISH_CYCLE_STATES.ClosingFunnelForRetry :				//
															IF funnel.closed THEN
																state.sb.finishCycle := FINISH_CYCLE_STATES.Start;
															END_IF												
	
	FINISH_CYCLE_STATES.BringSealFlattenersInAndDown :		//
															motorizedSealFlatteners.AutoMoveToHandLoad();
															state.sb.finishCycle := FINISH_CYCLE_STATES.BringingSealFlattenersInAndDown;
	
	FINISH_CYCLE_STATES.BringingSealFlattenersInAndDown :	//
															IF motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.Idle THEN
																state.sb.finishCycle := FINISH_CYCLE_STATES.SealFlattenersInAndDown;
															END_IF
	
	FINISH_CYCLE_STATES.SealFlattenersInAndDown :			//
															state.sb.finishCycle := FINISH_CYCLE_STATES.Shake;
	
	FINISH_CYCLE_STATES.BringSealFlattenersToBagHolding:	//
															motorizedSealFlatteners.AutoMoveToBagHolding();
															state.sb.finishCycle := FINISH_CYCLE_STATES.BringingSealFlattenersToBagHolding;
	
	FINISH_CYCLE_STATES.BringingSealFlattenersToBagHolding: //
															IF motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.Idle THEN
																state.sb.finishCycle := FINISH_CYCLE_STATES.SealFlattenersAtBagHolding;
															END_IF
																
	FINISH_CYCLE_STATES.SealFlattenersAtBagHolding : 		//
															state.sb.finishCycle := FINISH_CYCLE_STATES.Shake;
															
	FINISH_CYCLE_STATES.Shake:
		//
		IF loadShelf.shakeStart = SHAKER_START_SELECTION.BagOpen OR
   		   loadShelf.shakeStart = SHAKER_START_SELECTION.Both THEN
		   loadShelf.Shake();
		END_IF
		
		//
		IF rearLoadPlate.shakeStart = SHAKER_START_SELECTION.BagOpen OR
   		   rearLoadPlate.shakeStart = SHAKER_START_SELECTION.Both THEN
		   rearLoadPlate.Shake();
		END_IF
		
		//
		IF frontLoadPlate.shakeStart = SHAKER_START_SELECTION.BagOpen OR
   		   frontLoadPlate.shakeStart = SHAKER_START_SELECTION.Both THEN
		   frontLoadPlate.Shake();
		END_IF

		IF rearLoadPlate.Shaking OR frontLoadPlate.Shaking OR loadShelf.Shaking THEN
			state.sb.finishCycle := FINISH_CYCLE_STATES.Shaking;
		ELSIF zebraPrinter.enable AND HMIData.printerCycleSelection <> PrinterCycleSelection.PrintWhileFeeding THEN
			state.sb.finishCycle := FINISH_CYCLE_STATES.WaitForOutOfCyclePrint;
		ELSE
			state.sb.finishCycle := FINISH_CYCLE_STATES.Done;
		END_IF
	
	FINISH_CYCLE_STATES.Shaking:
		IF NOT frontLoadPlate.Shaking AND NOT rearLoadPlate.Shaking AND NOT loadShelf.Shaking THEN
			IF zebraPrinter.enable AND HMIData.printerCycleSelection <> PrinterCycleSelection.PrintWhileFeeding THEN
				state.sb.finishCycle := FINISH_CYCLE_STATES.WaitForOutOfCyclePrint;
			ELSE
				state.sb.finishCycle := FINISH_CYCLE_STATES.Done;
			END_IF
		END_IF	
	
	FINISH_CYCLE_STATES.WaitForOutOfCyclePrint:
		//
		IF bagOpened THEN
        	IF NOT bagOpenFingers.CheckIfBagGrabbed(FALSE) AND NOT HMIData.enableDryCycle THEN
				openedBagWasRemoved.Trigger();
				bagOpened := FALSE;
			END_IF
		END_IF
		
		IF state.sb.printOutOfCycle = PRINT_OUT_OF_CYCLE_STATES.Done THEN
			state.sb.printOutOfCycle := PRINT_OUT_OF_CYCLE_STATES.Idle;
			state.sb.finishCycle := FINISH_CYCLE_STATES.Done;
		END_IF	
	
	FINISH_CYCLE_STATES.Done :								
		//
		bagOpenRetryCount := 0;
END_CASE

_waitForSealFlattenersUpTimer(IN := state.sb.automation = AUTOMATION_STATES.MovingSealFlattenersUp);
CASE state.sb.automation OF
	
	AUTOMATION_STATES.MoveSealFlattenersUp:
		motorizedSealFlatteners.sealFlattenersVerticalAxis.Retract();
		state.sb.automation := AUTOMATION_STATES.MovingSealFlattenersUp;
		
	AUTOMATION_STATES.MovingSealFlattenersUp:	
		IF _waitForSealFlattenersUpTimer.Q THEN
			motorizedSealFlatteners.AutoMoveOut();
			state.sb.automation := AUTOMATION_STATES.MovingSealFlattenersOut;
		END_IF
		
	AUTOMATION_STATES.MoveSealFlattenersOut:	
		motorizedSealFlatteners.AutoMoveOut();
		state.sb.automation := AUTOMATION_STATES.MoveSealFlattenersOut;
	
	AUTOMATION_STATES.MovingSealFlattenersOut:
		IF motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersOut THEN
			motorizedSealFlatteners.Reset();
			state.sb.automation := AUTOMATION_STATES.MovedSealFlattenersIn;
		END_IF
		
	AUTOMATION_STATES.MovedSealFlattenersIn:
		state.sb.automation := AUTOMATION_STATES.DisableBagOpenSensing;
	
	AUTOMATION_STATES.DisableBagOpenSensing:
		bagOpened := FALSE;
		state.sb.automation := AUTOMATION_STATES.RaiseBOF;	
	
	AUTOMATION_STATES.RaiseBOF:
		bagOpenFingers.Release();
		state.sb.automation := AUTOMATION_STATES.Done; 
END_CASE

// Print out of cycle
_waitForTakeupTimer(IN := state.sb.printOutOfCycle = PRINT_OUT_OF_CYCLE_STATES.WaitForTakeup);
CASE state.sb.printOutOfCycle OF
	PRINT_OUT_OF_CYCLE_STATES.Idle:
		// Machine state machine will start this sub state by setting to "WaitForPrinter"
		
	PRINT_OUT_OF_CYCLE_STATES.WaitForPrinter:
		// Wait for label
		IF zebraPrinter.state = PRINTER_STATES.DataReady THEN
        	state.sb.printOutOfCycle := PRINT_OUT_OF_CYCLE_STATES.StartPrinting;
        END_IF
		
	PRINT_OUT_OF_CYCLE_STATES.StartPrinting:
		// Turn off power to rear motor and disable tension fault. Tell Zebra FB to prep for print cycle.
		zebraPrinter.AutoPrintNow();
		bagDelivery._bagFeedRearMotor.SetTorque(0);
		bagDelivery._bagFeedRearMotor.DisableTensionFault();
        state.sb.printOutOfCycle := PRINT_OUT_OF_CYCLE_STATES.SendPrintSignal;
	
	PRINT_OUT_OF_CYCLE_STATES.SendPrintSignal:
		// After print head and compensator are down, send the print and start barcode verifier
		IF zebraPrinter.printHeadDebounced THEN												
			zebraPrinter.AutoSendPrintSignal();
			barcodeVerifier.Trigger();
			state.sb.printOutOfCycle := PRINT_OUT_OF_CYCLE_STATES.Printing;
        END_IF
													
	PRINT_OUT_OF_CYCLE_STATES.Printing:
		// Wait for print to complete
		 IF zebraPrinter.state = PRINTER_STATES.DonePrinting THEN
         	state.sb.printOutOfCycle := PRINT_OUT_OF_CYCLE_STATES.FinishedPrinting;
         END_IF
		 
	PRINT_OUT_OF_CYCLE_STATES.FinishedPrinting:
		// All done. Tell Zebra FB that we see it finished, and up the torque on the rear motor to take up slack
		zebraPrinter.AutoAckPrintDone();
		bagDelivery._bagFeedRearMotor.SetTorque(100);
        state.sb.printOutOfCycle := PRINT_OUT_OF_CYCLE_STATES.WaitForTakeup;
		
	PRINT_OUT_OF_CYCLE_STATES.WaitForTakeup:
		// Change this to a rear motor move in reverse to take up faster?
		IF  _waitForTakeupTimer.Q THEN
			bagDelivery._bagFeedRearMotor.EnableTensionFault();
			//bagDelivery._bagFeedRearMotor.SetTorque((TO_DINT(HMIData.bagTensionSetting * 100)));
		END_IF
		state.sb.printOutOfCycle := PRINT_OUT_OF_CYCLE_STATES.Done;
		
	PRINT_OUT_OF_CYCLE_STATES.Done:
		// Machine state machine will set this back to idle.
		
	PRINT_OUT_OF_CYCLE_STATES.Fault:
		//
		
END_CASE

HMIData.initiateCycle := FALSE;