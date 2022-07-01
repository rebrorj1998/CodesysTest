(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MOABHead EXTENDS FB_BaseComponent
VAR_INPUT
    motorizedSealFlattenersMode : DEVICE_MODES := DEVICE_MODES.Auto;
    electricPressureBarMode : DEVICE_MODES := DEVICE_MODES.Auto;
	vacuumPickerMode : DEVICE_MODES;
    startCycle : BOOL;
    bagDeliveryMode : DEVICE_MODES;        // Mode of bag delivery system
    printerMode : DEVICE_MODES;            // Mode of printer
	passthroughMode : DEVICE_MODES;
	passthroughSetting : REAL;
    passthroughSettingLast : REAL;
	bagDropDelay : UINT := 1000;
	bagFeedMasterCommFail : BOOL;
	bagFeedSlaveCommFail : BOOL;
	pressureBarCommFail : BOOL;
	sealFlattenerCommFail : BOOL;
	infeedConveyorCommFail : BOOL;
	laserBarcodeScannerCommFail : BOOL;
END_VAR
VAR_OUTPUT
    readyToRun : BOOL;
    state : HEAD_STATES;
    sealAndSeparateSubState : SEAL_SEPARATE_STATES;
    releaseAndFeedSubState : RELEASE_FEED_STATES;
    openBagSubState : BAG_OPEN_ASSIST_STATES;
	finishCycleSubState : FINISH_CYCLE_STATES;
	pressureBarEndStopMotor : FB_AppliedMotionStepServoEIPPassthrough();
END_VAR
VAR
    motorizedSealFlatteners : FB_MotorizedSealFlatteners();
	msfVerticalAxis : FB_ThreePositionCylinder();
    pressureBar : FB_PneumaticPressureBar();
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
	zebraPrinter : FB_ZebraPrinter;
	sealTimer : Standard.TON() := (PT := T#350MS);
	bagOpenFingerDelay : Standard.TON := (PT := T#100MS);
	bagDropTimer : Standard.TON;
	HPA : FB_MonostableMultivibrator();
	exitConveyorRun : DelayDwellFB() := (Dwellsetting := 6000);
	externalExitConveyorRun : DelayDwellFB() := (Dwellsetting := 6000);
	IBDCylinders : FB_ThreePositionCylinder();
	IBDExtendONS : FB_ONS();
	IBDRetractONS : FB_ONS();
	IBDRetractToDeflate : FB_MonostableMultivibrator();
	IBDRetractToEject : FB_MonostableMultivibrator();
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
	passthrough : FB_AdjustablePneumaticPassthrough();
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
	infeedConveyorIOCommFail : FB_Fault(name := 'Infeed Conveyor IO Communication Failure');
	infeedConveyorVFDFaulted : FB_Fault(name := 'Infeed Conveyor VFD Failure');
	barcodeVerifierCommFail : FB_Fault(name := 'Barcode Verifier Communication Failure');
	sealFlattenerTimedOut : FB_Fault(name := 'Seal Flatteners Timed Out / Did Not Reach Destination');
	loadShelf : FB_BaseLoadPlate;
	rearLoadPlate : FB_BaseLoadPlate;
	frontLoadPlate : FB_BaseLoadPlate;
	iPowerOffButtonONS : FB_ONS();
	loadPlateFaultTimer : FB_CylinderFaults();
	forwardLoadPlateFaults : LoadPlateFaultsType;
	rearLoadPlateFaults : LoadPlateFaultsType;
	loadShelfFaults : LoadPlateFaultsType;
	LPA : DelayDwellFB();
	hpaServiceOnONS : FB_ONS;
	exitConveyorJogONS : FB_ONS;
	externalExitConveyorJogONS : FB_ONS;
	hmiLight  : FB_HMILight;
	faultONS : FB_ONS;
	powerSettlingTimer : Standard.TON := (PT := T#6S);
	pressureBarCloseDelay : Standard.TON;
	filler : FB_Filler();
	configOutput1Pulse : FB_MonostableMultivibrator();
	configOutput2Pulse : FB_MonostableMultivibrator();
	fillerModeCycleStartOnlyPulse : FB_MonostableMultivibrator();
    resetTimer : Standard.TOF := (PT := T#2S);
	murrIOBusNode : FB_MurrIO();
	funnel : FB_Funnel();
	barcodeVerifier : FB_BarcodeReader();
	keyenceBCV : FB_KeyenceNL20();
	rearMotorCommsReturned : Standard.F_TRIG();
	allMotorCommsGood : BOOL;
	footSwitchONS : FB_ONS;
	ezfeed : FB_EZFeed();
	stopONS : FB_ONS;
	pbarExtendedONS : FB_ONS;
	batchEnableONS : FB_ONS;
	exhaustTimer : TON := (PT := T#300MS);
	triggerLPAWhileFeedingONS : FB_ONS;
	eState: INT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: FB_MOABHead
//    Description: This is the supervisory module for the MOAB head.
//    There is one supervisory state machine for the head and 3 sub-state machines Sealing/Separating, Release/Feed, and Opening Bag
//    Created by: Ben Hess
//    Created Date: Tuesday, April 17, 2018

{region "Setup"}

{endregion}
// Run BaseComponentFB
SUPER^();

// When power is returned, give machine ~5 seconds
powerSettlingTimer(IN := iEStopOK);
Globals.machinePowerOK := powerSettlingTimer.Q;
safePowerFailure.faultTrigger := NOT iEStopOK AND murrIOBusNode.ok;

// Bags Low warning
HMIData.bagLevelLow.active := iBagsLow;

// Dry Cycle Warning
HMIData.dryCycleActive.active := HMIData.enableDryCycle;	

// Ethernet/IP barcode verifier from Keyence
keyenceBCV(
	enable:= , 
	ptrEIPInputs:= ADR(keyenceBCVInputs), 
	ptrEIPOutputs:= ADR(keyenceBCVOutputs), 
	triggerInput:= , 
	//commFail=> ,
	lastReadData => HMIData.barcodeLastReadString
);
	 
// Barcode Verifier interface to printer
barcodeVerifier(enable := (HMIData.barcodeVerifierSelection <> BCVSelection.NotInstalled AND HMIData.barcodeVerifierInUse),
		 		readGoodInput := keyenceBCV.goodRead,
				distanceToScan := HMIData.barcodeScanDistance,
				feedSpeed := TO_REAL(HMIData.printSpeed),
				positionOffset := HMIData.barcodeStartPosition,
				badReadFaultCountSetting := HMIData.barcodeBadReadFaultSetting,
				currentBadReadCount => HMIData.barcodeBadReadCount,
				currentGoodReadCount => HMIData.barcodeGoodReadCount,
				triggerScannerOutput => keyenceBCV.triggerInput
);
					 
// Enable comms to Keyence N-L20 if selected in factory config
IF HMIData.barcodeVerifierSelection = BCVSelection.LaserScanner THEN
	Keyence_BCV.Enable := TRUE; 
	IF laserBarcodeScannerCommFail THEN 
		barcodeVerifierCommFail.Trigger();
	END_IF
ELSE
	Keyence_BCV.Enable := FALSE;
END_IF

// Option setup and factory config  
IF HMIData.resetAverageCycleTime THEN
	HMIData.averageCycleTime := 0;
	HMIData.resetAverageCycleTime := FALSE;
END_IF
HMIData.lastCycleTime := cycleTime;

HMIData.printerNotReady.active := NOT printerReady AND zebraPrinter.enable;
HMIData.waitingForPrinter.active := zebraPrinter.state = PRINTER_STATES.WaitingForData AND releaseAndFeedSubState = RELEASE_FEED_STATES.WaitForPrinter;
	 
bagOpenRetrySetting := HMIData.bagOpenRetrySetting;
HMIData.bagOpenRetryCount := bagOpenRetryCount;
	 
// Run bus node		  
murrIOBusNode(
	enable:= , 
	headNodeEnabled:= TRUE, 
	guardNodeEnabled:= (HMIData.cycleStartButtonSelection <> PalmButtonSelection.NotInstalled) OR (HMIData.funnelFactorySelection <> FunnelSelection.NotInstalled), 
	printerNodeEnabled:= (HMIData.printerSelection <> LabelPrinterSelection.NotInstalled), 
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
						sealFlattenerMotorCommFailInput := (sealFlattenerCommFail AND motorizedSealFlatteners.enable),
						timeoutFault => sealFlattenerTimedOut.faultTrigger
);
motorizedSealFlatteners.Mode := motorizedSealFlattenersMode;
motorizedSealFlatteners.enable := (HMIData.sealFlattenersSelection = SealFlattenerSelection.MotorizedSealFlatteners) AND HMIData.sealFlattenersInUse;

// Setup of MOAB Machine Pressure bar ("#2") on actual machine, not test rig
pressureBar(
	iPressureBarExtended := iPressureBarExtended, 
	iPressureBarRetracted := iPressureBarRetracted, 
	iPressureBarNotObstructed := iPressureBarNotObstructed, 
	iLightCurtainsClear := iLightCurtainsClear,
	lightCurtainsInstalled := HMIData.lightCurtainSelection = LightCurtainsSelection.LoadingAreaLightCurtains,
	oExtendCylinder => oPBar1Extend, oRetractCylinder => oPBar1Retract,
	cumulativeHeadCycleCount := Globals.headCycleCount2
);
pressureBar.Mode := electricPressureBarMode;
	 
// Adding extra pressure bar valve for test
opBar2Extend := oPBar1Extend;
opbar2Retract := oPBar1Retract;

// Run bag delivery 
bagDelivery(
	jogForwardPB := HMIData.jogBagForward,
	jogReversePB := HMIData.jogBagReverse,
	bagLengthSetpoint := HMIData.bagLength,	 
	printVelocitySetpoint := HMIData.printSpeed,
	printLengthSetpoint := HMIData.printLength,
	sealOffsetSetpoint := HMIData.bagSkirtLength,
	reverseVelocitySetpoint := TO_INT(HMIData.bagReverseSpeed),
	feedVelocitySetpoint := TO_INT(HMIData.bagForwardSpeed),
	printOffsetSetpoint := HMIData.printOffset,	
	reverseToPrintheadRequired := zebraPrinter.enable,
	bagFeedMasterMotorCommFailInput := bagFeedMasterCommFail,
	bagFeedRearMotorCommFailInput := bagFeedSlaveCommFail,
	stepsPerInchSetting := Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY,
	velocityMultiplier := Globals.VELOCITY_IPS_MULTIPLIER_PNEUMATIC,
	rearMotorConfigVersion := HMIData.rearUnwindMotorConfigVersion	 
);
bagDelivery.Mode := bagDeliveryMode;

// Run Zebra Printer
zebraPrinter(ribbonEncoderPulse := iPrinterRibbonEncoder, oLowerPrintHead => oPrintHeadDown);
zebraPrinter.Mode := printerMode;
zebraPrinter.enable := (HMIData.printerSelection <> LabelPrinterSelection.NotInstalled) AND HMIData.printerInUse;
IF HMIData.activateDemoMode THEN
	HMIData.demoModeIsActive.active := TRUE;
	zebraPrinter.autoSendLabel := TRUE;
ELSE
	HMIData.demoModeIsActive.active := FALSE;
	zebraPrinter.autoSendLabel := FALSE;
END_IF
	 
// Run funnel
funnel(
	enable:= HMIData.funnelFactorySelection <> FunnelSelection.NotInstalled AND HMIData.funnelInUse, 
	sensorsInstalled:= HMIData.funnelFactorySelection = FunnelSelection.FunnelWithSensors, 
	openSensor:= iFunnelOpened, 
	closedSensor:= iFunnelClosed, 
	opened=> , 
	closed=> , 
	closeOutput=> oIBDRetract, 
	openOutput=> oIBDExtend, 
	failToOpen=> , 
	failToClose=> );
funnel.OpeningTime := HMIData.funnelOpeningTime;
funnel.ClosingTime := HMIData.funnelClosingTime;
funnel.DelaySetting := HMIData.funnelOpenDelay;

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

triggerLPAWhileFeedingONS(CLK := releaseAndFeedSubState = RELEASE_FEED_STATES.MovingJawOutAndFeedingBag);
IF HMIData.lpaDuringBagFeedEnable AND triggerLPAWhileFeedingONS.OSR THEN
    LPA.DwellSetting := TO_DINT(((bagDelivery.remainingLength - HMIData.bagSkirtLength) / TO_REAL(HMIData.bagForwardSpeed)) * 1000.0);
    LPA.Trigger();
END_IF
LPA(Q => oLPAOn);
	 
CASE HMIData.independentBagDeflatorSelection OF
	BagDeflatorSelection.NotInstalled:					// Disable IBD
		 													enableIBDDeflate := FALSE;
															enableIBDEject := FALSE;
															IBDRetractToDeflate.DelaySetting := 0;
															IBDRetractToDeflate.DwellSetting := 0;
															IBDRetractToEject.DelaySetting := 0;
															IBDRetractToEject.DwellSetting := 0;
	
	BagDeflatorSelection.IBDStandard:	// Enable IBD
															IBDRetractToDeflate();
															IBDRetractToEject();
															IBDRetractONS(CLK := (IBDRetractToDeflate.Q OR IBDRetractToEject.Q));
															IBDExtendONS(CLK := NOT (IBDRetractToDeflate.Q OR IBDRetractToEject.Q));
																 
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
	 														IBDCylinders(extendOutput => oIBDExtend, retractOutput => oIBDRetract);
															IF IBDRetractONS.OSR THEN
																IBDCylinders.Retract();
															END_IF
															IF IBDExtendONS.OSR THEN
																IBDCylinders.Extend();
															END_IF
																 
															IBDRetractToDeflate.DelaySetting := 0;
															IBDRetractToDeflate.DwellSetting := TO_UINT(HMIData.IBDDeflateDwellTime * 1000);
															IBDRetractToEject.DelaySetting := TO_UINT(HMIData.IBDPackageEjectAssistDelayTime * 1000);
															IBDRetractToEject.DwellSetting := TO_UINT(HMIData.IBDPackageEjectAssistDwellTime * 1000);
																 
	BagDeflatorSelection.IBDWithHingedPlate:	// Enable IBD with Hinged Plate
															enableIBDDeflate := TRUE;
															IBDCylinders(extendOutput => oIBDExtend, retractOutput => oIBDRetract);	
															oIBDRetract := IBDRetractToDeflate.Q OR IBDRetractToEject.Q;
															oIBDExtend := NOT oIBDRetract;
															IBDRetractToDeflate.DelaySetting := 0;
															IBDRetractToDeflate.DwellSetting := TO_UINT(HMIData.IBDDeflateDwellTime * 1000);
															IBDRetractToEject.DelaySetting := TO_UINT(HMIData.IBDPackageEjectAssistDelayTime * 1000);
															IBDRetractToEject.DwellSetting := TO_UINT(HMIData.IBDPackageEjectAssistDwellTime * 1000);
	
END_CASE

CASE HMIData.bofSelection OF
	BagOpenFingersSelection.NotInstalled:					// Disable Bag Open
		 													enableBagOpen := FALSE;
															
	
	BagOpenFingersSelection.PneumaticWithBagOpenSensors:	// Enable Bag Open
															enableBagOpen := TRUE;
END_CASE

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
END_CASE
startCycleReqFromPalmButtonsONS(CLK := startCycleReqFromPalmButtons);	 

HMIData.lightCurtainsBlocked.active := (NOT iLightCurtainsClear AND HMIData.lightCurtainSelection = LightCurtainsSelection.LoadingAreaLightCurtains);	 
	 
		  
CASE HMIData.auxIOConfig.factorySelection OF
	AuxiliaryIOSelection.NotInstalled:					// Turn outputs off
		 												oAuxBaggerOK := FALSE;
														oAuxReadyForFiller := FALSE;
														configOutput1Pulse.ManualOff();	
														configOutput1Pulse.Reset();
														configOutput2Pulse.ManualOff();	
														configOutput2Pulse.Reset();
														murrIOBusNode.auxIONodeEnabled := FALSE;
														IF HMIData.fillerFactorySelection = FillerSelection.StandardFiller THEN
															HMIData.fillerFactorySelection := FillerSelection.NotInstalled;
														END_IF
		 
	AuxiliaryIOSelection.AuxIOStandard:					// Use aux IO
		 												murrIOBusNode.auxIONodeEnabled := TRUE;
		 												oAuxBaggerOK := NOT HMIData.faultActive;
														oAuxReadyForFiller := filler.waitingForFiller;					
															 
 														CASE HMIData.auxIOConfig.cfgInput1Selection OF
															AuxInputSelection.NotConfigured:		
																// 
																HMIData.baggerInhibited.active := FALSE;
																										 
															AuxInputSelection.BaggerInhibit:		
																//
																HMIData.baggerInhibited.active := iAuxConfigInput1;
																
															AuxInputSelection.FillerOK:           
																 //
																filler.fillerOK := iAuxConfigInput1; 
														END_CASE
														
														CASE HMIData.auxIOConfig.cfgInput2Selection OF
															AuxInputSelection.NotConfigured:		
																// 
																HMIData.baggerInhibited.active := FALSE;
																										 
															AuxInputSelection.BaggerInhibit:		
																//
																HMIData.baggerInhibited.active := iAuxConfigInput2;
																
															AuxInputSelection.FillerOK:           
																 //
																filler.fillerOK := iAuxConfigInput2; 
														END_CASE
 
														CASE HMIData.auxIOConfig.cfgOutput1Selection OF
																 
															AuxOutputSelection.BagMade:				//
																 									IF state = HEAD_STATES.SealedAndSeparatedBag THEN
																										configOutput1Pulse.Trigger();
																									END_IF
																										 
															AuxOutputSelection.CycleComplete:		//
																 									IF state = HEAD_STATES.OpenedBag THEN
																										configOutput1Pulse.Trigger();
																									END_IF
																										 
															AuxOutputSelection.PrinterDataReady:	//
																 									IF printerDataReady THEN
																										configOutput1Pulse.ManualOn();
																									ELSE
																										configOutput1Pulse.ManualOff();
																									END_IF
																										 
															AuxOutputSelection.WaitingForPrinter:	// 
																 									IF releaseAndFeedSubState = RELEASE_FEED_STATES.WaitForPrinter THEN
																										configOutput1Pulse.ManualOn();
																									ELSE
																										configOutput1Pulse.ManualOff();	
																								    END_IF
																										 
															AuxOutputSelection.BagMadePlusLabelRequired:	//
																 									IF NOT printerDataReady AND state = HEAD_STATES.SealedAndSeparatedBag THEN
																										configOutput1Pulse.ManualOn();
																									END_IF
																									
																									IF printerDataReady OR HMIData.faultActive OR (releaseAndFeedSubState = RELEASE_FEED_STATES.FeedToOffset) THEN
																										configOutput1Pulse.ManualOff();
																									END_IF 
															AuxOutputSelection.BagsLow:				//
																									IF HMIData.bagLevelLow.active THEN
																										configOutput1Pulse.ManualOn();
																									ELSE
																										configOutput1Pulse.ManualOff();
																									END_IF											 
															
														END_CASE
															 
														CASE HMIData.auxIOConfig.cfgOutput2Selection OF
																 
															AuxOutputSelection.BagMade:				//
																 									IF state = HEAD_STATES.SealedAndSeparatedBag THEN
																										configOutput2Pulse.Trigger();
																									END_IF
																										 
															AuxOutputSelection.CycleComplete:		//
																 									IF state = HEAD_STATES.OpenedBag THEN
																										configOutput2Pulse.Trigger();
																									END_IF
																										 
															AuxOutputSelection.PrinterDataReady:	//
																 									IF printerDataReady THEN
																										configOutput2Pulse.ManualOn();
																									ELSE
																										configOutput2Pulse.ManualOff();
																									END_IF
																										 
															AuxOutputSelection.WaitingForPrinter:	// 
																 									IF releaseAndFeedSubState = RELEASE_FEED_STATES.WaitForPrinter THEN
																										configOutput2Pulse.ManualOn();
																									ELSE
																										configOutput2Pulse.ManualOff();	
																								    END_IF
																										 
															AuxOutputSelection.BagMadePlusLabelRequired:	//
																 									IF NOT printerDataReady AND state = HEAD_STATES.SealedAndSeparatedBag THEN
																										configOutput2Pulse.ManualOn();
																									END_IF
																									
																									IF printerDataReady OR HMIData.faultActive OR (releaseAndFeedSubState = RELEASE_FEED_STATES.FeedToOffset) THEN
																										configOutput2Pulse.ManualOff();
																									END_IF 
																										 
															AuxOutputSelection.BagsLow:				//
																									IF HMIData.bagLevelLow.active THEN
																										configOutput2Pulse.ManualOn();
																									ELSE
																										configOutput2Pulse.ManualOff();
																									END_IF	
														END_CASE
														
		 
END_CASE 
	 
// Pulse outputs that are temporary statuses (Cycle Complete) vs. held (Waiting for Printer) 
configOutput1Pulse(Q => oAuxConfigOut1);
configOutput2Pulse(Q => oAuxConfigOut2);
configOutput1Pulse.DwellSetting := 500;
configOutput2Pulse.DwellSetting := 500;
 // Filler and EZFeed conveyor setup
CASE HMIData.fillerFactorySelection OF
	FillerSelection.NotInstalled:					// No filler
		 											filler.enable := FALSE;
													filler.activateFiller := FALSE;
													HMIData.fillerEnable := FALSE;	
													ezfeed.enable := FALSE;
													fillerModeCycleStartOnlyPulse.Reset();
													Infeed_Conveyor_IO.Enable := FALSE;
		 
	FillerSelection.StandardFiller:					// Only enable filler if Aux IO is enabled
		 											filler.enable := (HMIData.auxIOConfig.factorySelection = AuxiliaryIOSelection.AuxIOStandard);
													Infeed_Conveyor_IO.Enable := FALSE;
														 
	FillerSelection.EZFeed:							filler.enable := TRUE;
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
	IF infeedConveyorCommFail THEN 
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
	fillerTrigger:= iAuxFillerTrigger OR (ezfeed.EZFeedDone AND NOT HMIData.stopMachine), 
	activateFiller:= HMIData.fillerEnable, 
	dropTime:= HMIData.fillerDropTime,
	state => , 
	fillerModeActive => , 
	waitingForFiller => ,
	cycleBagRequest => , 
	cycleBaggerToActivateFiller => , 
	notReady => );	 
IF filler.activateFiller AND NOT filler.cycleBaggerToActivateFiller.active THEN
	IF (HMIData.initiateCycle OR startCycleReqFromPalmButtons) AND NOT HMIData.infeedConveyorOutOfParts.active THEN
		fillerModeCycleStartOnlyPulse.Trigger();
	END_IF
END_IF

//	 
HMIData.packageEjectGuardRemoved.active := HMIData.packageEjectSelection = PackageEjectionSelection.LabelSideUp AND NOT iPackageEjectGuardClosed;

//
loadShelf(
	switchedPowerON := iEStopOK,
	faultsEnabled := FALSE,
	inUse := HMIData.loadPlateInUse,
    shakerEnable := HMIData.shakerInstalled,
	shakeStart := HMIData.loadShelfShakerStart,
	shakerDwell := HMIData.loadShelfShakerDwell,
	shakerDelay := HMIData.loadShelfShakerDelay,
	shakerOnDwell := HMIData.loadShelfShakerOnDuration,
	shakerOffDwell := HMIData.loadShelfShakerOffDuration,
	disabledPosition := HMIData.packageEjectDisabledPosition,
	moveToLoadingPositon => oLoadShelfUp,
	moveToDischargePosition => oLoadShelfDown
);		 
HMIData.loadShelfService.extendedFeedback := rearLoadPlate.inLoadingPosition;
HMIData.loadShelfService.retractedFeedback := rearLoadPlate.inDischargePosition;

//	 
rearLoadPlate(
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
	moveToLoadingPositon => oloadPlateExtend,
	moveToDischargePosition => oLoadPlateRetract,
	failedToExtend => rearLoadPlateFaults.failedToLoad.faultTrigger,
	failedToRetract => rearLoadPlateFaults.failedToDischarge.faultTrigger
);		 
HMIData.rearLoadPlateService.extendedFeedback := HMIData.loadPlateService.extendedFeedback := rearLoadPlate.inLoadingPosition;
HMIData.rearLoadPlateService.retractedFeedback := HMIData.loadPlateService.retractedFeedback :=  rearLoadPlate.inDischargePosition;

//	 
frontLoadPlate(
	switchedPowerON := iEStopOK,
	inUse := HMIData.loadPlateInUse,
	inLoadingPosition := iFrontLoadPlateRetracted,
	inDischargePosition := iFrontLoadPlateExtended,
	triggerDwell := HMIData.loadPlateDwell,
	triggerDelay := HMIData.loadPlateDelay,
    shakerEnable := HMIData.shakerInstalled,
	shakeStart := HMIData.frontloadPlateShakerStart,
	shakerDwell := HMIData.frontLoadPlateShakerDwell,
	shakerDelay := HMIData.frontLoadPlateShakerDelay,
	shakerOnDwell := HMIData.frontLoadPlateShakerOnDuration,
	shakerOffDwell := HMIData.frontLoadPlateShakerOffDuration,
	disabledPosition := HMIData.packageEjectDisabledPosition,
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
														frontLoadPlate.faultsEnabled := state >= HEAD_STATES.ReleaseAndFeedBag;
														rearLoadPlate.triggerDelay := 0;
														rearLoadPlate.triggerDwell := HMIData.loadPlateDwell + HMIData.loadPlateDelay;
														loadShelf.triggerDelay := HMIData.loadShelfDelay;
														loadShelf.triggerDwell := HMIData.loadShelfDwell;
															 
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

exitConveyorRun();
exitConveyorRun.DwellSetting := TO_DINT(HMIData.exitConveyorDwell * 1000);
exitConveyorJogONS(CLK := HMIData.exitConveyorJog);
oRunExitConveyor := exitConveyorRun.Q AND HMIData.integratedExitConveyorSelection = IntegratedConveyorSelection.RearExit;
	 
externalExitConveyorRun();
externalExitConveyorRun.DwellSetting := TO_UINT(HMIData.externalExitConveyorDwell * 1000);
externalExitConveyorJogONS(CLK := HMIData.externalExitConveyorJog);
oRunExternalExitConveyor := externalExitConveyorRun.Q AND HMIData.externalExitConveyorSelection <> ExteralConveyorSelection.NotInstalled;

bagOpenFingers(enable := HMIData.bofSelection <> BagOpenFingersSelection.NotInstalled,
				releaseOutput => oBOFUp,
		 		grabOutput => oBOFDown,
				rightFingerBagPresent := iRightFingerBagPresent,
				leftFingerBagPreset := iLefttFingerBagPresent,
				bagFailedToGrabBothFingersCount := Globals.bagFailedToGrabBothFingersCount,
				bagFailedToGrabLeftFingerCount := Globals.bagFailedToGrabLeftFingerCount,
				bagFailedToGrabRightFingerCount := Globals.bagFailedToGrabRightFingerCount,
				successfulBagOpenCount := Globals.successfulBagOpenCount);

// Setup and run adjustable passthrough
//refIECObject := Pbar_ServoEIP;
pressureBarEndStopMotor(ptrEIPInputs := ADR(jawPasstrhoughMotorInputs),
                ptrEIPOutputs := ADR(jawPasstrhoughMotorOutputs),
                stepsPerInchSetpoint := Globals.STEPS_PER_INCH_SHOW_MOTOR,
				reversePolarity := TRUE,
				defaultCurrentSetpoint := 650,
				commFail := pressureBarCommFail,
				isHomable := TRUE);			
pressureBarEndStopMotor.Execute();

passthrough(pressureBarEndStopMotor := pressureBarEndStopMotor, 
			cumulativeChangeCount := Globals.passthroughChangeCount2, 
			cumulativeChangeDistance := Globals.passthroughChangeDistance2,
			jogInPB := HMIData.jogPassthroughForward,
			jogOutPB := HMIData.jogPassthroughReverse,
			passthroughPosition => HMIData.passthroughPosition);
passthrough.Mode := passthroughMode;

{endregion}
	 
hmiLight(lightOutput => oHMILight);
faultONS(CLK := HMIData.faultActive);

readyToRun := (motorizedSealFlatteners.Ready OR NOT motorizedSealFlatteners.enable) 
                AND (pressureBar.Ready OR NOT pressureBar.enable)
                AND (bagDelivery.Ready OR NOT bagDelivery.enable)
                AND (zebraPrinter.Ready OR NOT zebraPrinter.enable)
				AND (passthrough.Ready OR NOT passthrough.enable)
				AND murrIOBusNode.ok;
iPowerOffButtonONS(CLK := iPowerOffButton);

resetTimer(IN := iPowerOffButtonONS.OSR);
IF iPowerOffButtonONS.OSR THEN
    reset();
END_IF
				
IF HMIData.makeReady OR resetTimer.Q THEN
	HMIData.ackAllFaults := TRUE;
	enable := TRUE;
	
	bagDropTimer.IN := FALSE;
	
	motorizedSealFlattenersMode := DEVICE_MODES.Auto;
	motorizedSealFlatteners.Reset();
	IF motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.HomeRequired AND motorizedSealFlatteners.enable THEN
		motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.HomeNow();
		motorizedSealFlatteners.sealFlattenersVerticalAxis.Retract();
	END_IF
	
	HMIData.bagOpenFeedNewBagCount := 0;
	bagOpenRetryCount := 0;
	
	HMIData.stopMachine := FALSE;
	
	electricPressureBarMode := DEVICE_MODES.Auto;
	pressureBar.Reset();
	pressureBar.enable := TRUE;

	enableHeater := TRUE;
	
	bagDeliveryMode := DEVICE_MODES.Auto;
	bagDelivery.Reset();
	bagDelivery.enable := TRUE;
	IF iPowerOffButtonONS.OSR THEN
		bagDelivery.AutoFeedToEye();
		IF NOT passthrough.homeRequired THEN
			IF NOT iPressureBarExtended THEN
				pressureBar.AutoOpenJaw();
			ELSE
				pressureBar.ExhaustCylinder();
			END_IF
		END_IF
	END_IF
	IF passthrough.homeRequired THEN
		homeJawPB := TRUE;
	END_IF
	bagOpened := FALSE;
	
	printerMode := DEVICE_MODES.Auto;
	zebraPrinter.Reset();

	IF iPowerOffButtonONS.OSR AND NOT bagDelivery.bagTensionFault.active THEN
		IF (HMIData.factoryTestMode AND (HMIData.bagsMade.count < 1000)) THEN
			bagDelivery._bagFeedRearMotor.SetTorque((TO_DINT(HMIData.bagTensionSetting * 100)));
		END_IF 
	END_IF  
	passthrough.Reset();
	pressureBarEndStopMotor.Reset();
	passthroughMode := DEVICE_MODES.Auto;
	passthrough.enable := TRUE;
	
	oVacOn := FALSE;
	rearLoadPlate.Reset();
	frontLoadPlate.Reset();
	loadShelf.Reset();
	IBDRetractToDeflate.Reset();
	IBDRetractToEject.Reset();
	IBDCylinders.Extend();
	LPA.Reset();
	LPA.ManualOff();
	HPA.Reset();
	funnel.CloseNow();
	exitConveyorRun.Reset();
	externalExitConveyorRun.Reset();
	oSealBarExtend := FALSE;
	oSealBarRetract := TRUE;
	sealTimer.IN := FALSE;
	pressureBarCloseDelay.IN := FALSE;
	filler.Reset();
	configOutput1Pulse.Reset();
	configOutput2Pulse.Reset();
	configOutput1Pulse.ManualOff();
	configOutput2Pulse.ManualOff();
	fillerModeCycleStartOnlyPulse.Reset();
	barcodeVerifier.Reset();
	keyenceBCV.Reset();
	ezFeed.Reset();

	state := HEAD_STATES.Idle;
	reset();
	setPassthroughPB := FALSE; 

	HMIData.jobLoadRequired.active := TRUE;
	HMIData.makeReady := FALSE;
	hmiLight.TurnOff();
	autoModeKeepCycling := FALSE;
END_IF
IF enableONS.Q OR resetONS.Q THEN
    state := HEAD_STATES.Idle;
	sealAndSeparateSubState := SEAL_SEPARATE_STATES.Idle;
	releaseAndFeedSubState := RELEASE_FEED_STATES.Idle;
	openBagSubState := BAG_OPEN_ASSIST_STATES.Idle;
	finishCycleSubState := FINISH_CYCLE_STATES.Idle;
	motorizedSealFlatteners.Reset();
	pressureBar.Reset();
	bagDelivery.Reset();
	zebraPrinter.Reset();

	bagDropTimer.IN := FALSE;
	_reset := FALSE;
	cycleTimer.IN := FALSE;
END_IF

{warning 'TODO: Put this inside the passtrough FB'}
IF passthrough.exhaustPressureBarRequest THEN
    pressureBar.ExhaustCylinder();
	IBDCylinders.Exhaust();
	IF NOT oPBar1Extend AND NOT oPBar1Retract THEN
		passthrough.AckRequest();
	END_IF
ELSIF passthrough.extendPressureBarRequest THEN
    pressureBar.ExtendCylinderHighPressure();
	IBDCylinders.Extend();
	IF oPBar1Extend AND NOT oPBar1Retract THEN
		passthrough.AckRequest();
	END_IF
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
IF HMIData.batchCountDone.active OR NOT HMIData.autoEnable THEN
	autoModeKeepCycling := FALSE;
END_IF

IF NOT enable OR NOT readyToRun OR faultONS.OSR THEN
    state := HEAD_STATES.Fault;
	pressureBarEndStopMotor.Stop();
	cycleTimer.IN := FALSE;
END_IF
pressureBarCloseDelay(PT := TO_TIME(HMIData.pressureBarCloseDelay * 1000));
cycleTimer();

autoModeKeepCyclingTimer(PT := TO_TIME(HMIData.autoModeDwell * 1000), IN := autoModeKeepCycling AND state = HEAD_STATES.Idle);

HMIData.mayCycleUnexpectedly.active := autoModeSelected OR filler.activateFiller;

exhaustTimer(IN := iPressureBarExtended AND state = HEAD_STATES.Idle);

footSwitchONS(CLK := iFootSwitch);

stopONS(CLK := HMIDAta.stopMachine);

IF state <> HEAD_STATES.Idle AND HMIData.initiateCycle THEN
	HMIData.initiateCycle := FALSE;
END_IF
CASE state OF
    HEAD_STATES.Idle :                              // Start cycle if enabled
                                                    IF (startCycle AND (filler.cycleBaggerToActivateFiller.active OR NOT filler.activateFiller)
													OR (HMIData.factoryTestMode AND (HMIData.bagsMade.count < 1000)) AND (factoryTestModeKeepCycling AND NOT LPA.Q)
													OR (startCycleReqFromPalmButtonsONS.OSR) AND (filler.cycleBaggerToActivateFiller.active OR NOT filler.activateFiller)
													OR (HMIData.initiateCycle AND (filler.cycleBaggerToActivateFiller.active OR NOT filler.activateFiller))
													OR (filler.cycleBagRequest AND HMIData.autoEnable)
													OR ((filler.cycleBagRequest AND NOT HMIData.autoEnable) AND (footSwitchONS.OSR OR HMIData.initiateCycle OR startCycleReqFromPalmButtonsONS.OSR))
													OR (autoModeKeepCyclingTimer.Q)
													OR footSwitchONS.OSR AND (filler.cycleBaggerToActivateFiller.active OR NOT filler.activateFiller))
													AND (NOT HMIData.faultActive 
													AND NOT HMIData.stopMachine 
													AND NOT HMIData.baggerInhibited.active
													AND NOT HMIData.sealBarNotAtTemperature.active
													AND NOT HMIData.batchCountDone.active
													AND NOT setPassthroughPB
													AND NOT EZFeed.emptyPartsWarning)
													AND readyToRun 
													THEN
                                                        state := HEAD_STATES.SealAndSeparateBag;
                                                        startCycle := FALSE;
														
														cycleTimer.IN := TRUE;
                                                    END_IF
													IF NOT Globals.passthroughChangedFromJog AND HMIData.jobLoaded THEN
														HMIData.jobLoaded := FALSE;
													END_IF
                                                    IF (HMIData.passthroughSetting <> passthroughSettingLast) OR (Globals.passthroughChangedFromJog AND HMIData.jobLoaded) AND NOT pressureBarEndStopMotor.Faulted AND NOT pressureBarEndStopMotor.HomeRequired THEN
															setPassthroughPB := TRUE;
															Globals.passthroughChangedFromJog := FALSE;
															HMIData.jobLoaded := FALSE;
															passthroughSetting := HMIData.passthroughSetting;
															passthroughSettingLast := HMIData.passthroughSetting;
													END_IF
													
													IF (NOT (pressureBarEndStopMotor.HomeRequired OR pressureBarEndStopMotor.Faulted))
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
														//state := HEAD_STATES.Fault;
														//HMIData.stopMachine := FALSE;
													END_IF
													
													pbarExtendedONS(CLK := exhaustTimer.Q);
													IF pbarExtendedONS.OSR THEN
														pressureBar.ExhaustCylinder();
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
														state := HEAD_STATES.MovePassthrough;
													END_IF
													IF homeJawPB THEN
														hmiLight.BlinkSlow();
														state := HEAD_STATES.StartHoming;
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
														IBDCylinders.Retract();
														HMIData.IBDService.retractCommand := FALSE;
													END_IF                                      
                                                    
													IF HMIData.IBDService.extendCommand THEN
														IBDCylinders.Extend();
														HMIData.IBDService.extendCommand := FALSE;
													END_IF	
														 
													IF HMIData.funnelService.retractCommand THEN
														funnel.OpenNow();
														HMIData.funnelService.retractCommand := FALSE;
													END_IF                                      
                                                    
													IF HMIData.funnelService.extendCommand THEN
														funnel.CloseNow();
														HMIData.funnelService.extendCommand := FALSE;
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
                                                    
    HEAD_STATES.SealAndSeparateBag :                // Begin Seal and Separate State machine
													filler.BaggerCycleInitiated();
                                                    HMIData.inCycle := TRUE;
													HMIData.airFilterClean.Increment();
													HMIData.baggerCycles.Increment();
													IF funnel.enable THEN
														funnel.CloseNow();
													END_IF
													
													IF bagOpenFingers.CheckIfBagGrabbed(FALSE) THEN
														bagOpened := TRUE;
													END_IF
													
                                                    state := HEAD_STATES.SealingAndSeparatingBag;
                                                    sealAndSeparateSubState := SEAL_SEPARATE_STATES.Shake;
                
    HEAD_STATES.SealingAndSeparatingBag :            IF sealAndSeparateSubState = SEAL_SEPARATE_STATES.Done THEN
                                                        state := HEAD_STATES.SealedAndSeparatedBag;
                                                        sealAndSeparateSubState := SEAL_SEPARATE_STATES.Idle;
                                                    END_IF    

    HEAD_STATES.SealedAndSeparatedBag :                state := HEAD_STATES.ReleaseAndFeedBag;                                    
                                                    
    HEAD_STATES.ReleaseAndFeedBag :                    // Open the jaw and release the bag
                                                    releaseAndFeedSubState := RELEASE_FEED_STATES.MoveJawOutAndDropBag;
                                                    state := HEAD_STATES.ReleasingAndFeedingBag;
                                                    
    HEAD_STATES.ReleasingAndFeedingBag :            // 
                                                    IF releaseAndFeedSubState = RELEASE_FEED_STATES.Done THEN
                                                        state := HEAD_STATES.ReleasedAndFedBag;
                                                        releaseAndFeedSubState := RELEASE_FEED_STATES.Idle;
                                                    END_IF
                                                    
    HEAD_STATES.ReleasedAndFedBag :                    // 
                                                    IF HMIData.batchEnable THEN
                                                        HMIData.batchCount := HMIData.batchCount + 1;
                                                    END_IF
  
                                                    IF HMIData.enableDryCycle THEN
                                                        Globals.dryCycleCount := Globals.dryCycleCount + 1;     
                                                    ELSE
                                                        Globals.bagsMadeCount := Globals.bagsMadeCount + 1; 
                                                    END_IF
													IF enableBagOpen THEN
                                                        state := HEAD_STATES.OpenBag;
                                                    ELSE
                                                        state := HEAD_STATES.FinishCycle;
                                                    END_IF
                                                                    
    HEAD_STATES.OpenBag :                            // Close jaw to grab the bag
                                                    openBagSubState := BAG_OPEN_ASSIST_STATES.MoveJawIn;
                                                    state := HEAD_STATES.OpeningBag;
                                                    
                                                    
    HEAD_STATES.OpeningBag :                        // Open jaw and grab onto the bag
                                                    IF openBagSubState = BAG_OPEN_ASSIST_STATES.Done THEN
                                                        state := HEAD_STATES.OpenedBag;
                                                        openBagSubState := BAG_OPEN_ASSIST_STATES.Idle;
													ELSIF openBagSubState = BAG_OPEN_ASSIST_STATES.FeedNewBag THEN
														state := HEAD_STATES.SealAndSeparateBag;
														openBagSubState := BAG_OPEN_ASSIST_STATES.Idle;
                                                    END_IF
                                                    
    HEAD_STATES.OpenedBag :                            // Move fingers in and to bag holding and reset cycle
                                                    IF (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.Idle OR NOT motorizedSealFlatteners.enable) //OR bagFailedToOpen
														 AND pressureBar.state = PRESSURE_BAR_STATES.JawOpened THEN
														state := HEAD_STATES.FinishCycle;
                                                    END_IF
	HEAD_STATES.FinishCycle :			//
													finishCycleSubState := FINISH_CYCLE_STATES.Start;
													state := HEAD_STATES.FinishingCycle;
	HEAD_STATES.FinishingCycle : 		//
													IF finishCycleSubState = FINISH_CYCLE_STATES.Done THEN
														state := HEAD_STATES.FinishedCycle;
														finishCycleSubState := FINISH_CYCLE_STATES.Idle;
													END_IF
	HEAD_STATES.FinishedCycle :			//
											HMIData.bagsMade.Increment();
											HMIData.resettableBagsMade.Increment();
                                            state := HEAD_STATES.Idle;
											IF NOT HMIData.stopMachine THEN
												filler.BaggerCycledAndReady();
											END_IF
											cycleTime := (TIME_TO_REAL(cycleTimer.ET) / 1000); 
											cycleTimer.IN := FALSE;
											IF HMIData.averageCycleTime = 0 THEN
												HMIData.averageCycleTime := cycleTime;
											ELSE
												HMIData.averageCycleTime := (cycleTime + HMIData.averageCycleTime) / 2;
											END_IF
											HMIData.inCycle := FALSE;
											//bagFailedToOpen := FALSE;
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
											
    HEAD_STATES.StartHoming:                // 
                                            passthrough.HomeEndStop();
                                            state := HEAD_STATES.Homing;                                        
    
    HEAD_STATES.Homing:                     // 
                                            IF passthrough.state = PASSTHROUGH_SERVO_STATES.HomeComplete THEN
                                                state := HEAD_STATES.HomingComplete;       
                                            END_IF
                                            
    HEAD_STATES.HomingComplete:             // 
                                            homeJawPB := FALSE;
                                            state := HEAD_STATES.Idle;
											setPassthroughPB := TRUE;
    
    HEAD_STATES.MovePassthrough:            // 
                                            pressureBar.AutoMovingPassthrough();
                                            passthrough.MovePassthrough(passthroughSetting);
                                            state := HEAD_STATES.MovingPassthrough;
    
    HEAD_STATES.MovingPassthrough:          IF passthrough.state = PASSTHROUGH_SERVO_STATES.PassthroughMovedIn OR passthrough.state = PASSTHROUGH_SERVO_STATES.PassthroughMovedOut THEN
                                                state := HEAD_STATES.MovedPassthrough;     
                                            END_IF
                                            
    HEAD_STATES.MovedPassthrough:           // 
                                            pressureBar.AutoDoneMovingPassthrough();
                                            state := HEAD_STATES.Idle;
											setPassthroughPB := FALSE;
                                                    
    HEAD_STATES.Fault:                      hmiLight.TurnOff();
											HMIData.inCycle := FALSE;
											cycleTimer.IN := FALSE;
									   		bagDelivery._bagFeedFrontMotor.
											bagDelivery._bagFeedRearMotor.TriggerPointToPointMode();
											sealAndSeparateSubState := SEAL_SEPARATE_STATES.Idle;
											releaseAndFeedSubState := RELEASE_FEED_STATES.Idle;
											openBagSubState := BAG_OPEN_ASSIST_STATES.Idle;
											finishCycleSubState := FINISH_CYCLE_STATES.Idle;
											oVacOn := FALSE;
											filler.Reset();
											ezFeed.Reset();
											LPA.ManualOff();
											IBDRetractToDeflate.Reset();
											IBDRetractToEject.Reset();
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

CASE sealAndSeparateSubState OF
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
			sealAndSeparateSubState := SEAL_SEPARATE_STATES.Shaking;
		ELSIF enableIBDDeflate THEN
			sealAndSeparateSubState := SEAL_SEPARATE_STATES.BringInIBD;
		ELSE
			sealAndSeparateSubState := SEAL_SEPARATE_STATES.WaitForJawCloseDelay;
		END_IF
													
	SEAL_SEPARATE_STATES.Shaking:				    //
		IF NOT frontLoadPlate.Shaking AND NOT rearLoadPlate.Shaking AND NOT loadShelf.Shaking THEN
			IF enableIBDDeflate THEN
				sealAndSeparateSubState := SEAL_SEPARATE_STATES.BringInIBD;
			ELSE
				sealAndSeparateSubState := SEAL_SEPARATE_STATES.WaitForJawCloseDelay;
			END_IF
		END_IF	 
	
	SEAL_SEPARATE_STATES.BringInIBD : 				// Bring in IBD if enabled
													IF enableIBDDeflate THEN
														IBDRetractToDeflate.Trigger();
													END_IF 
													
													sealAndSeparateSubState := SEAL_SEPARATE_STATES.WaitForJawCloseDelay;
	
	SEAL_SEPARATE_STATES.WaitForJawCloseDelay : 	// Wait for jaw close delay. 
													IF pressureBar.enable THEN
														LPA.ManualOff();
														pressureBarCloseDelay.IN := TRUE;
														IF (pressureBarCloseDelay.Q OR HMIData.pressureBarCloseDelay = 0)
															AND (funnel.closed OR NOT funnel.enable)
															THEN
															sealAndSeparateSubState := SEAL_SEPARATE_STATES.MoveJawIn;
															pressureBarCloseDelay.IN := FALSE;
														END_IF
                                                    ELSE 
                                                        sealAndSeparateSubState := SEAL_SEPARATE_STATES.ReverseBag;
                                                    END_IF
        
    SEAL_SEPARATE_STATES.MoveJawIn :                // Perform actions as enabled - close jaw and move flatteners out. If jaw is disabled then go right to reverse bag
                                                    IF motorizedSealFlatteners.enable THEN
                                                        motorizedSealFlatteners.AutoMoveOut();
                                                    END_IF
                                                    
													pressureBar.AutoCloseJaw();
                                                    sealAndSeparateSubState := SEAL_SEPARATE_STATES.MovingJawIn;
                                                    
                                                
    SEAL_SEPARATE_STATES.MovingJawIn :                // If Jaw is in and flatteners out then move on
                                                    IF (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersOut OR NOT motorizedSealFlatteners.enable) 
                                                        AND (pressureBar.state = PRESSURE_BAR_STATES.JawClosed OR NOT pressureBar.enable)
                                                        THEN
                                                            sealAndSeparateSubState := SEAL_SEPARATE_STATES.MovedJawIn;    
                                                    END_IF
                                                                
    SEAL_SEPARATE_STATES.MovedJawIn :                // Will add sealing logic here
                                                    sealAndSeparateSubState := SEAL_SEPARATE_STATES.ReverseBag;
                                                    
    SEAL_SEPARATE_STATES.ReverseBag :                // Reverse bag if bag delivery enabled, otherwise open jaw
													IBDRetractToDeflate.Reset();
                                                    IF bagDelivery.enable THEN
                                                        bagDelivery.AutoReverseBag();
                                                        sealAndSeparateSubState := SEAL_SEPARATE_STATES.ReversingBag;
                                                    ELSE sealAndSeparateSubState := SEAL_SEPARATE_STATES.Done;    
                                                    END_IF
                                                                    
    SEAL_SEPARATE_STATES.ReversingBag :                // 
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
                                                        AND (pressureBar.state = PRESSURE_BAR_STATES.JawClosed OR NOT pressureBar.enable)
                                                        AND (bagDelivery.state = BAG_DELIVERY_STATES.ReverseDone OR NOT bagDelivery.enable)
														AND (sealTimer.Q OR HMIData.separateBeforeSeal)
                                                        THEN
															IF NOT HMIData.separateBeforeSeal THEN
																HMIData.sealBarCycles.Increment();
															END_IF
															
															sealTimer.IN := FALSE;
                                                            sealAndSeparateSubState := SEAL_SEPARATE_STATES.Reversedbag;
                                                    END_IF
    SEAL_SEPARATE_STATES.Reversedbag :                
													// 
                                                    sealAndSeparateSubState := SEAL_SEPARATE_STATES.SealBag;
													
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
															sealAndSeparateSubState := SEAL_SEPARATE_STATES.Done;
														END_IF
													ELSE
														sealAndSeparateSubState := SEAL_SEPARATE_STATES.Done;
													END_IF
													
END_CASE


CASE releaseAndFeedSubState OF
    RELEASE_FEED_STATES.MoveJawOutAndDropBag :        // 
                                                    IF (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersOut OR NOT motorizedSealFlatteners.enable) 
                                                        AND (pressureBar.state = PRESSURE_BAR_STATES.JawClosed OR NOT pressureBar.enable)
                                                        AND ((bagDelivery.state = BAG_DELIVERY_STATES.ReverseDone) OR HMIData.enableDryCycle)
                                                        OR (bagDelivery.state =  BAG_DELIVERY_STATES.WaitingForPrinter AND zebraPrinter.enable)
                                                        OR NOT bagDelivery.enable
                                                        THEN
                                                            IF motorizedSealFlatteners.enable THEN
                                                                motorizedSealFlatteners.AutoMoveToClearance();
                                                            END_IF
                                                            
                                                            IF pressureBar.enable THEN
                                                                pressureBar.AutoOpenJaw();
                                                            END_IF
                                                            
															IF enableBagOpen THEN
																bagOpenFingers.Release();
															END_IF
															
															IF enableIBDEject THEN
																IBDRetractToEject.Trigger();
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
															
															IF TO_DINT(HMIData.externalExitConveyorDwell) <> 0 THEN
																externalExitConveyorRun.Trigger();
															END_IF
															
															IF HMIData.lpaBagEjectAssistEnable THEN
																LPA.ManualOn();
															END_IF
                                                           bagDropTimer.IN := TRUE;
														   releaseAndFeedSubState := RELEASE_FEED_STATES.MovingJawOutAndDroppingBag;
                                                    END_IF
													
	 RELEASE_FEED_STATES.MovingJawOutAndDroppingBag :
														 // If printer is enabled then perform printer operation of bag delivery, otherwise just feed new bag out.
                                                            // In the case that bagDelivery is disabled then we're done with release and feed
                                                        IF bagDropTimer.Q 
															AND (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersToBagFeed OR NOT motorizedSealFlatteners.enable)
															THEN   
															bagDropTimer.IN := FALSE;
															IBDRetractToEject.Reset();
															IBDRetractToDeflate.Reset();
															IF bagDelivery.enable AND NOT zebraPrinter.enable THEN
                                                                bagDelivery.AutoFeedBagOut();
 																LPA.ManualOff();
// 																IF HMIData.lpaDuringBagFeedEnable THEN
// 																	LPA.ManualOn();
// 																END_IF
                                                                releaseAndFeedSubState := RELEASE_FEED_STATES.MovingJawOutAndFeedingBag;
                                                            ELSIF bagDelivery.enable AND zebraPrinter.enable THEN
                                                                bagDelivery.AutoWaitForPrinter();
																LPA.ManualOff();
                                                                releaseAndFeedSubState := RELEASE_FEED_STATES.WaitForPrinter;
                                                            ELSE 
                                                                releaseAndFeedSubState := RELEASE_FEED_STATES.Done;
                                                            END_IF
                                                            (*{warning 'TODO: This is a hack to use HPA as LPA'}
														    HPA.DwellSetting := 500;		// Get rid on this - ha
													        HPA.Trigger();*)												
    													END_IF
														
    RELEASE_FEED_STATES.WaitForPrinter :            // Data Ready means the printer has a label and we're all set to print
                                                    IF zebraPrinter.state = PRINTER_STATES.DataReady THEN
														IF HMIData.lpaDuringBagFeedEnable THEN
															LPA.ManualOn();
														END_IF
                                                        releaseAndFeedSubState := RELEASE_FEED_STATES.FeedToOffset;
                                                    END_IF
                                                    
    RELEASE_FEED_STATES.FeedToOffset :                // This starts feeding to the print offset
													IF (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersToBagFeed OR NOT motorizedSealFlatteners.enable) THEN
														bagDelivery.AutoPrinterReady();
                                                    	releaseAndFeedSubState := RELEASE_FEED_STATES.FeedingToOffset;
													END_IF
                                                    
                                                        
    RELEASE_FEED_STATES.FeedingToOffset :            // Once offset done start printing
                                                    IF bagDelivery.state = BAG_DELIVERY_STATES.FedToPrintOffset THEN
                                                        releaseAndFeedSubState := RELEASE_FEED_STATES.StartPrinting;
                                                    END_IF                                            
    
    RELEASE_FEED_STATES.StartPrinting :                // Printer starts print cycle and bag delivery starts moving at print speed
                                                    
                                                    //bagDelivery.AutoStartPrintFeed();
													zebraPrinter.AutoPrintNow();
                                                    
                                                    releaseAndFeedSubState := RELEASE_FEED_STATES.SendPrintSignal;                                            

    RELEASE_FEED_STATES.SendPrintSignal:            // 
                                                    //IF bagDelivery.state =     BAG_DELIVERY_STATES.FeedingAtPrintSpeed THEN
													//zebraPrinter.AutoSendPrintSignal();
													IF zebraPrinter.printHeadDebounced THEN
														bagDelivery.AutoStartPrintFeed();
														zebraPrinter.AutoSendPrintSignal();
														barcodeVerifier.Trigger();
                                                        //bagDelivery.AutoStartPrintFeed();
														//bagDelivery.AutoStartPrintFeed();
                                                        //zebraPrinter.AutoSendPrintSignal();
														
                                                        releaseAndFeedSubState := RELEASE_FEED_STATES.Printing;
                                                    END_IF                                        

    RELEASE_FEED_STATES.Printing :                // 
													
                                                    IF zebraPrinter.state = PRINTER_STATES.DonePrinting THEN
                                                        releaseAndFeedSubState := RELEASE_FEED_STATES.StopPrinting;
                                                    END_IF
                                                    
    RELEASE_FEED_STATES.StopPrinting :                // Tell bag delivery it's okay to feed out the rest of the bag and the printer that it can prep itself for the next print
                                                    bagDelivery.AutoPrinterDone();
                                                    zebraPrinter.AutoAckPrintDone();
													
                                                    releaseAndFeedSubState := RELEASE_FEED_STATES.MovingJawOutAndFeedingBag;
                                                                                
                                                                                                            
    RELEASE_FEED_STATES.MovingJawOutAndFeedingBag :    // 
//     												IF (bagdelivery.state = BAG_DELIVERY_STATES.Ready OR NOT bagdelivery.enable) THEN
// 														LPA.ManualOff();
// 													END_IF
													
													IF (bagdelivery.state = BAG_DELIVERY_STATES.Ready OR NOT bagdelivery.enable)
                                                        AND (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersToBagFeed OR NOT motorizedSealFlatteners.enable) 
                                                        AND (pressureBar.state = PRESSURE_BAR_STATES.JawOpened OR NOT pressureBar.enable)
                                                        THEN
															IBDRetractToEject.Reset();
                                                            releaseAndFeedSubState := RELEASE_FEED_STATES.MovedJawOutAndFedBag;
                                                    END_IF
                                                    
    RELEASE_FEED_STATES.MovedJawOutAndFedBag :      // Wait until bag is fed out before triggering barcode fail.
													IF barcodeVerifier.barcodeFault THEN
														barcodeVerificationFailed.Trigger();
													END_IF 
													releaseAndFeedSubState := RELEASE_FEED_STATES.Done;
													
    RELEASE_FEED_STATES.Done :
    RELEASE_FEED_STATES.Fault :
END_CASE

CASE openBagSubState OF
    BAG_OPEN_ASSIST_STATES.Idle :                    // 
                                                    
                                                    
                                                    
    BAG_OPEN_ASSIST_STATES.MoveJawIn :                // Close jaw against bag. In the future we may also start vacuum here
                                                    pressureBar.AutoCloseJaw();
													(*HPA.DwellSetting := 80;
													HPA.Trigger();*)
													IF HPA.DwellSetting <> 0 THEN
														HPA.Trigger();	
													END_IF
													
													//oVacOn := TRUE; // Hard coded for now, this is vacuum
                                                    openBagSubState := BAG_OPEN_ASSIST_STATES.MovingJawIn;        
                                                    
                                                    
    BAG_OPEN_ASSIST_STATES.MovingJawIn :            // Move on once jaw is closed
                                                    IF (pressureBar.state = PRESSURE_BAR_STATES.JawClosed) OR NOT pressureBar.enable THEN
                                                        openBagSubState := BAG_OPEN_ASSIST_STATES.MovedJawIn;        
                                                    END_IF
                                                    
                                                    
    BAG_OPEN_ASSIST_STATES.MovedJawIn :                // Hold onto the bag with vacuum to build suction
                                                    vacuumHoldTimer.IN := TRUE;
													oVacOn := TRUE; // Hard coded for now, this is vacuum
													IF vacuumHoldTimer.Q THEN
														openBagSubState := BAG_OPEN_ASSIST_STATES.MoveJawOut; 
														vacuumHoldTimer.IN := FALSE;
													END_IF
                                                                   
                                                    
                                                    
    BAG_OPEN_ASSIST_STATES.MoveJawOut :                // Open the jaw 
                                                    pressureBar.AutoOpenJaw();
                                                    openBagSubState := BAG_OPEN_ASSIST_STATES.MovingJawOutAndGrab;
                                                    
                                                    
    BAG_OPEN_ASSIST_STATES.MovingJawOutAndGrab :    // WAit for delay, and move in seal flatteners at the same time as bag grab
													bagOpenFingerDelay.IN := TRUE;
													IF bagOpenFingerDelay.Q THEN
														bagOpenFingers.Grab();
														bagOpenFingerDelay.IN := FALSE;
														motorizedSealFlatteners.AutoMoveIn();
														openBagSubState := BAG_OPEN_ASSIST_STATES.CheckForSuccessfulBagGrab;
													END_IF
													  

	BAG_OPEN_ASSIST_STATES.CheckForSuccessfulBagGrab : 	//
														IF bagOpenRetryCount < bagOpenRetrySetting THEN
															bagOpenCheckDelay.IN := TRUE;
															IF bagOpenCheckDelay.Q THEN
																IF bagOpenFingers.CheckIfBagGrabbed(TRUE) OR HMIData.enableDryCycle THEN // This method checks to see if the bag is grabbed and returns true if so.
																	openBagSubState := BAG_OPEN_ASSIST_STATES.BagOpened;
																	motorizedSealFlatteners.AutoMoveIn();
																ELSE 
																	openBagSubState := BAG_OPEN_ASSIST_STATES.BagFailedToOpen;
																END_IF
																bagOpenCheckDelay.IN := FALSE;
															END_IF
														ELSE 
															motorizedSealFlatteners.AutoMoveToBagHolding();
															openBagSubState := BAG_OPEN_ASSIST_STATES.MovingJawOutAfterGrab;
														END_IF
													  
	BAG_OPEN_ASSIST_STATES.BagFailedToOpen :			// 
														bagOpenFingers.Release();
														bagOpenRetryCount := bagOpenRetryCount + 1;
														IF bagOpenRetryCount < bagOpenRetrySetting THEN
															openBagSubState := BAG_OPEN_ASSIST_STATES.MoveJawIn;
														ELSIF HMIData.bagOpenFeedNewBagCount < HMIData.bagOpenFeedNewBagSetting THEN
															HMIData.bagOpenFeedNewBagCount := HMIData.bagOpenFeedNewBagCount + 1;
															bagOpenRetryCount := 0;
															motorizedSealFlatteners.AutoMoveOut();
															oVacOn := FALSE;
															openBagSubState := BAG_OPEN_ASSIST_STATES.FeedNewBag;
															
														ELSE 
															//IF (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.Idle OR NOT motorizedSealFlatteners.enable) THEN
																motorizedSealFlatteners.AutoMoveToBagHolding();
																bagFailedToOpen.Trigger();
																
																openBagSubState := BAG_OPEN_ASSIST_STATES.MovingJawOutAfterGrab;
																bagOpenRetryCount := 0; 
																HMIData.bagOpenFeedNewBagCount := 0;
																HMIData.bagsRejectedTotal.Increment();
																Globals.rejectedBagCount := Globals.rejectedBagCount + 1;
															//END_IF
															
														END_IF
	
	BAG_OPEN_ASSIST_STATES.BagOpened :					//
														bagOpened := TRUE;
                                                    	motorizedSealFlatteners.AutoMoveToBagHolding();
														bagOpenRetryCount := 0;
														HMIData.bagOpenFeedNewBagCount := 0;
														
														openBagSubState := BAG_OPEN_ASSIST_STATES.MovingJawOutAfterGrab; 
														
                                      
    BAG_OPEN_ASSIST_STATES.MovingJawOutAfterGrab :		// 
														IF (pressureBar.state = PRESSURE_BAR_STATES.JawOpened OR NOT pressureBar.enable) 
															AND (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.Idle OR NOT motorizedSealFlatteners.enable)
															THEN
																openBagSubState := BAG_OPEN_ASSIST_STATES.MovedJawOut;        
														END_IF	 
														
	
	BAG_OPEN_ASSIST_STATES.MovedJawOut :            // 
														oVacOn := FALSE; 		// Hard coded for now, this is vacuum
														
														
														openBagSubState := BAG_OPEN_ASSIST_STATES.Done;

                                                             
                                                
	BAG_OPEN_ASSIST_STATES.FeedNewBag :   			//
													IF (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.Idle OR NOT motorizedSealFlatteners.enable) THEN
														state := HEAD_STATES.SealAndSeparateBag;
													END_IF
													
													
                                                
    BAG_OPEN_ASSIST_STATES.Done :                    // 
                                                            
    BAG_OPEN_ASSIST_STATES.Fault :                    //
													

END_CASE

CASE finishCycleSubState OF
	FINISH_CYCLE_STATES.Idle:								//
	
	FINISH_CYCLE_STATES.Start :								//
															IF funnel.enable THEN
																finishCycleSubState := FINISH_CYCLE_STATES.OpenFunnel;
															ELSIF enableBagOpen THEN
																finishCycleSubState := FINISH_CYCLE_STATES.Shake;
															ELSE
																IF motorizedSealFlatteners.enable THEN
																	finishCycleSubState := FINISH_CYCLE_STATES.BringSealFlattenersInAndDown;
																ELSE
																	finishCycleSubState := FINISH_CYCLE_STATES.Shake;
																END_IF
															END_IF
															IF LPA.DwellSetting <> 0 THEN
																LPA.DwellSetting := TO_DINT(HMIData.lpaDwell * 1000);
																LPA.Trigger();
															END_IF
	
	FINISH_CYCLE_STATES.OpenFunnel :						//
															IF LPA.DwellSetting <> 0 THEN
																LPA.DwellSetting := TO_DINT(HMIData.lpaDwell * 1000);
																LPA.Trigger();
															END_IF
															funnel.OpenNow();
															finishCycleSubState := FINISH_CYCLE_STATES.OpeningFunnel;
	
	FINISH_CYCLE_STATES.OpeningFunnel :						//
															IF funnel.opened THEN
																finishCycleSubState := FINISH_CYCLE_STATES.OpenedFunnel;
															END_IF
	
	FINISH_CYCLE_STATES.OpenedFunnel :						//
															//IF enableBagOpen THEN
																IF iLefttFingerBagPresent AND iRightFingerBagPresent THEN
																	finishCycleSubState := FINISH_CYCLE_STATES.Shake;
																ELSE
																	IF bagOpenRetryCount < bagOpenRetrySetting THEN
																		bagOpenRetryCount := bagOpenRetryCount + 1;
																		funnel.CloseNow();
																		finishCycleSubState := FINISH_CYCLE_STATES.ClosingFunnelForRetry;
																	ELSE
																		bagFailedToOpen.Trigger();
																		funnel.CloseNow();
																		bagOpenRetryCount := 0; 
																		HMIData.bagsRejectedTotal.Increment();
																		finishCycleSubState := FINISH_CYCLE_STATES.Shake;
																	END_IF
																END_IF
															ELSE
																IF motorizedSealFlatteners.enable THEN
																	finishCycleSubState := FINISH_CYCLE_STATES.BringSealFlattenersToBagHolding;
																ELSE
																	finishCycleSubState := FINISH_CYCLE_STATES.Shake;
																END_IF
															//END_IF
	
	FINISH_CYCLE_STATES.ClosingFunnelForRetry :				//
															IF funnel.closed THEN
																finishCycleSubState := FINISH_CYCLE_STATES.Start;
															END_IF												
	
	FINISH_CYCLE_STATES.BringSealFlattenersInAndDown :		//
															motorizedSealFlatteners.AutoMoveToHandLoad();
															finishCycleSubState := FINISH_CYCLE_STATES.BringingSealFlattenersInAndDown;
	
	FINISH_CYCLE_STATES.BringingSealFlattenersInAndDown :	//
															IF motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.Idle THEN
																finishCycleSubState := FINISH_CYCLE_STATES.SealFlattenersInAndDown;
															END_IF
	
	FINISH_CYCLE_STATES.SealFlattenersInAndDown :			//
															finishCycleSubState := FINISH_CYCLE_STATES.Shake;
	
	FINISH_CYCLE_STATES.BringSealFlattenersToBagHolding:	//
															motorizedSealFlatteners.AutoMoveToBagHolding();
															finishCycleSubState := FINISH_CYCLE_STATES.BringingSealFlattenersToBagHolding;
	
	FINISH_CYCLE_STATES.BringingSealFlattenersToBagHolding: //
															IF motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.Idle THEN
																finishCycleSubState := FINISH_CYCLE_STATES.SealFlattenersAtBagHolding;
															END_IF
																
	FINISH_CYCLE_STATES.SealFlattenersAtBagHolding : 		//
															finishCycleSubState := FINISH_CYCLE_STATES.Shake;
															
	FINISH_CYCLE_STATES.Shake:
		//
loadShelf.Shake();
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
		
		//
		IF rearLoadPlate.Shaking OR frontLoadPlate.Shaking OR loadShelf.Shaking THEN
			finishCycleSubState := FINISH_CYCLE_STATES.Shaking;
		ELSE
			finishCycleSubState := FINISH_CYCLE_STATES.Done;
		END_IF
	
	FINISH_CYCLE_STATES.Shaking:
		//
		IF NOT frontLoadPlate.Shaking AND NOT rearLoadPlate.Shaking AND NOT loadShelf.Shaking THEN
			finishCycleSubState := FINISH_CYCLE_STATES.Done;
		END_IF	
	
	FINISH_CYCLE_STATES.Done :								
		//
		bagOpenRetryCount := 0;
END_CASE
HMIData.initiateCycle := FALSE;