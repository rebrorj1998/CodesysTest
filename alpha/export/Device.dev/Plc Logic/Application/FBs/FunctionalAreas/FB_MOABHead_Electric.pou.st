(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MOABHead_Electric EXTENDS BaseComponentFB
VAR_INPUT
    motorizedSealFlattenersMode : DEVICE_MODES := DEVICE_MODES.Auto;
    electricPressureBarMode : DEVICE_MODES := DEVICE_MODES.Auto;
	vacuumPickerMode : DEVICE_MODES;
    startCycle : BOOL;
    bagDeliveryMode : DEVICE_MODES;        // Mode of bag delivery system
    printerMode : DEVICE_MODES;        // Mode of printer
	passthroughMode : DEVICE_MODES;
    batchSetting : DINT;            // Batch setpoint
    batchCount : DINT;                // Actual batch cycles
    enableBatch : BOOL;                // Enable Batch Mode
    enableBatchONS : F_TRIG;
	passthroughSetting : REAL;
    passthroughSettingLast : REAL;
	bagDropDelay : UINT := 1000;
END_VAR
VAR_OUTPUT
    readyToRun : BOOL;
    state : HEAD_STATES;
    sealAndSeparateSubState : SEAL_SEPARATE_STATES;
    releaseAndFeedSubState : RELEASE_FEED_STATES;
    openBagSubState : BAG_OPEN_ASSIST_STATES;
	finishCycleSubState : FINISH_CYCLE_STATES;
END_VAR
VAR
    motorizedSealFlatteners : MotorizedSealFlattenersFB_BagFeed();
	msfVerticalAxis : FB_ThreePositionCylinder();
    pressureBar : FB_MotorizedPressureBar();
	IBD : FB_MotorizedIBD();
	sealBarTempSensor : FB_IFMTempSensor();
	sealBarHeater : FB_TempController();
    startCycleONS : R_TRIG;
	enableBagOpen : BOOL;
	enableLoadPlate : BOOL;
	enableHeater : BOOL;
	enableIBDDeflate : BOOL;
	enableIBDEject : BOOL;
	enableLabelSideUp : BOOL := TRUE;
	factoryTestModeKeepCycling : BOOL;
    bagDelivery : BagDeliveryFB();
    //zebraPrinter : PrinterFB;            //Printer Test Rig
	zebraPrinter : PrinterFB_Mode2;
	sealTimer : Standard.TON() := (PT := T#350MS);
	bagOpenFingerDelay : Standard.TON := (PT := T#100MS);
	bagDropTimer : Standard.TON;
	HPA : MonostableMultivibratorFB();
    rearLoadPlateRetract : MonostableMultivibratorFB() := (Dwellsetting := 1500);
	forwardLoadPlateRetract : MonostableMultivibratorFB() := (Dwellsetting := 1500);
	loadShelfExtend : MonostableMultivibratorFB() := (Dwellsetting := 1500);
	exitConveyorRun : DelayDwellFB() := (Dwellsetting := 6000);
	externalExitConveyorRun : DelayDwellFB() := (Dwellsetting := 6000);
	//IBDCylinders : FB_ThreePositionCylinder();
	IBDExtendONS : FB_ONS();
	IBDRetractONS : FB_ONS();
	//IBDRetractToDeflate : MonostableMultivibratorFB();
	//IBDRetractToEject : MonostableMultivibratorFB();
	bagOpenFingers : BagOpenFingersWithSensorsFB();
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
	//passthrough : AdjustablePassthroughFB();
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
	iPowerOffButtonONS : FB_ONS();
	loadPlateFaultTimer : FB_CylinderFaults();
	loadPlateFaults : LoadPlateFaultsType;
	forwardLoadPlateFaultTimer : FB_CylinderFaults();
	forwardLoadPlateFaults : LoadPlateFaultsType;
	rearLoadPlateFaultTimer : FB_CylinderFaults();
	rearLoadPlateFaults : LoadPlateFaultsType;
	loadShelfFaultTimer : FB_CylinderFaults();
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
	filler : FillerFB();
	configOutput1Pulse : MonostableMultivibratorFB();
	configOutput2Pulse : MonostableMultivibratorFB();
	fillerModeCycleStartOnlyPulse : MonostableMultivibratorFB();
	murrIOBusNode : MurrIOFB();
	funnel : FunnelFB();
	barcodeVerifier : BarcodeReaderFB();
	keyenceBCV : KeyenceNL20FB();
	rearMotorCommsReturned : Standard.F_TRIG();
	baggerHeadMovement : FB_BaggerHeadRaise();
	resettingActive : BOOL;
	resetTimer : Standard.TOF := (PT := T#1S);
	allMotorCommsGood : BOOL;
	lightedPalmButton : FB_MurrK50;
	footSwitchONS : FB_ONS;
	IBDOffset : REAL := 2.0;
	IBDOutSetting: REAL;
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

		  
// When power is returned, give machine ~5 seconds
powerSettlingTimer(IN := iEStopOK);
Globals.machinePowerOK := powerSettlingTimer.Q;
safePowerFailure.faultTrigger := NOT iEStopOK AND murrIOBusNode.ok;

// Bags Low warning
HMIData.bagLevelLow.active := iBagsLow;

// Ethernet/IP barcode verifier from Keyence
keyenceBCV(
	enable:= , 
	ptrEIPInputs:= ADR(keyenceBCVInputs), 
	ptrEIPOutputs:= ADR(keyenceBCVOutputs), 
	triggerInput:= , 
	commFail=> ,
	lastReadData => HMIData.barcodeLastReadString);	 
// Barcode Verifier interface to printer
barcodeVerifier(enable := (HMIData.barcodeVerifierSelection <> BCVSelection.NotInstalled AND HMIData.barcodeVerifierInUse),
		 		readGoodInput := keyenceBCV.goodRead,
				distanceToScan := HMIData.barcodeScanDistance,
				feedSpeed := TO_REAL(HMIData.printSpeed),
				positionOffset := HMIData.barcodeStartPosition,
				badReadFaultCountSetting := HMIData.barcodeBadReadFaultSetting,
				currentBadReadCount => HMIData.barcodeBadReadCount,
				currentGoodReadCount => HMIData.barcodeGoodReadCount,
				triggerScannerOutput => keyenceBCV.triggerInput);
// Enable comms to Keyence N-L20 if selected in factory config
IF HMIData.barcodeVerifierSelection = BCVSelection.LaserScanner THEN
	Keyence_BCV.Enable := TRUE; 

	IF Keyence_BCV.eState <> IoDrvEthernetIP.AdapterState.RUNNING THEN 
		barcodeVerifierCommFail.Trigger();
	END_IF

ELSE
	Keyence_BCV.Enable := FALSE;
END_IF

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
	faultIndication:= HMIData.faultActive, 
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

HMIData.printerNotReady.active := NOT printerReady AND zebraPrinter.enable;
HMIData.waitingForPrinter.active := zebraPrinter.state = PRINTER_STATES.WaitingForData AND releaseAndFeedSubState = RELEASE_FEED_STATES.WaitForPrinter;
//HMIData.printerRibbonLow.active := printerRibbonLow;
	 
batchSetting := HMIData.batchSetting;
HMIData.batchCount := batchCount;

bagOpenRetrySetting := HMIData.bagOpenRetrySetting;
HMIData.bagOpenRetryCount := bagOpenRetryCount;
	 
// Run bus node		  
murrIOBusNode(
	enable:= , 
	headNodeEnabled:= TRUE, 
	guardNodeEnabled:= (HMIData.cycleStartButtonSelection = PalmButtonSelection.SinglePalmButton 
						OR HMIData.cycleStartButtonSelection = PalmButtonSelection.DualPalmButton
						OR (HMIData.funnelFactorySelection <> FunnelSelection.NotInstalled)), 
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
						manualPosSetpoint := HMIData.sealFlattenersManualPositionSetting);
motorizedSealFlatteners.Mode := motorizedSealFlattenersMode;
pressureBarMotor(ptrEIPInputs := ADR(jawPasstrhoughMotorInputs),
                ptrEIPOutputs := ADR(jawPasstrhoughMotorOutputs),
                stepsPerInchSetpoint := Globals.STEPS_PER_INCH_TFBelt,
                //faultHandler := PRG_Bagger.faultHandler,
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
	iPressureBarClamped:= iJawClamped, 
	iPressureBarClosed:= iJawClearToClamp, 
	iPressureBarNotObstructed:= TRUE, 
	iBaggerEnableButton:= , 
	iJawClampExtended:= iJawClampsExtended, 
	iJawCLampRetracted:= iJawClampsRetracted, 
	pbarOutSetting:= HMIData.passthroughSetting, 
	pbarInSetting:= , 
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
bagDelivery(jogForwardPB := HMIData.jogBagForward,
			jogReversePB := HMIData.jogBagReverse);
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
// Setup of pick and place motors


sealBarTempSensor(ptrTemperatureBytes := ADR(iHeaterBarTempInputs));
sealBarTempSensor.Execute();
sealBarHeater(enable := NOT safePowerFailure.active,
				temperatureSensor := sealBarTempSensor,
				temperatureSetpoint := TO_REAL(HMIData.sealBarTemperatureSetting),
				heaterPulse => 	oHeaterPulse);	  
HMIData.sealBarTemperature := TO_UDINT(sealBarHeater.currentTemp);
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

LPA.DwellSetting := TO_DINT(HMIData.lpaDwell * 1000);
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

CASE HMIData.bofSelection OF
	BagOpenFingersSelection.NotInstalled:					// Disable Bag Open
		 													enableBagOpen := FALSE;
															
	
	BagOpenFingersSelection.PneumaticWithBagOpenSensors:	// Enable Bag Open
															enableBagOpen := TRUE;
	
END_CASE


CASE HMIData.packageEjectSelection OF
	PackageEjectionSelection.NotInstalled:				// Disable all
														enableLoadPlate := FALSE;
														enableLabelSideUp := FALSE;	
														loadPlateFaultTimer.enable := FALSE;	
														forwardLoadPlateFaultTimer.enable := FALSE;
														rearLoadPlateFaultTimer.enable := FALSE;
														loadShelfFaultTimer.enable := FALSE;
		 
	PackageEjectionSelection.RearRetractingLoadPlate:	// Enable rear retracting load plate
		 												enableLoadPlate := TRUE;
														enableLabelSideUp := FALSE;	
														loadPlateFaultTimer.enable := Globals.machinePowerOK;	
														forwardLoadPlateFaultTimer.enable := FALSE;
														rearLoadPlateFaultTimer.enable := FALSE;
														loadShelfFaultTimer.enable := FALSE;
														rearLoadPlateRetract.DelaySetting := TO_UINT(HMIData.loadPlateDelay * 1000);
														rearLoadPlateRetract.DwellSetting := TO_UINT(HMIData.loadPlateDwell * 1000);
	
	PackageEjectionSelection.LabelSideUp:				// Enable all
		 												enableLoadPlate := TRUE;
														enableLabelSideUp := TRUE;	
														loadPlateFaultTimer.enable := FALSE;
														forwardLoadPlateFaultTimer.enable := Globals.machinePowerOK;
														rearLoadPlateFaultTimer.enable := Globals.machinePowerOK;
														//loadShelfFaultTimer.enable := Globals.machinePowerOK;
														rearLoadPlateRetract.DelaySetting := 0;
														rearLoadPlateRetract.DwellSetting := TO_UINT((HMIData.loadPlateDwell + HMIData.loadPlateDelay) * 1000);
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
															 
	PalmButtonSelection.LightedPalmButton:				// Lighted Murr palm button input comes from IO Link
		 												startCycleReqFromPalmButtons := iMurrTouchButtonStatus.0;
															 
END_CASE
startCycleReqFromPalmButtonsONS(CLK := startCycleReqFromPalmButtons);	 

lightedPalmButton(	baggerReady:= readyToRun AND NOT HMIData.sealBarNotAtTemperature.active, 
					baggerFaulted:= HMIData.faultActive, 
					baggerInCycle:= HMIData.inCycle, 
					IOLinkStateOutput=> oMurrTouchbuttonState);

		  
CASE HMIData.auxIOConfig.factorySelection OF
	AuxiliaryIOSelection.NotInstalled:					// Turn outputs off
		 												oAuxBaggerOK := FALSE;
														oAuxReadyForFiller := FALSE;
														configOutput1Pulse.ManualOff();	
														configOutput1Pulse.Reset();
														configOutput2Pulse.ManualOff();	
														configOutput2Pulse.Reset();
														murrIOBusNode.auxIONodeEnabled := FALSE;
														HMIData.fillerFactorySelection := FillerSelection.NotInstalled;
		 
	AuxiliaryIOSelection.AuxIOStandard:					// Use aux IO
		 												murrIOBusNode.auxIONodeEnabled := TRUE;
		 												oAuxBaggerOK := NOT HMIData.faultActive;
														oAuxReadyForFiller := filler.waitingForFiller;
															 
 														CASE HMIData.auxIOConfig.cfgInputSelection OF
															AuxInputSelection.NotConfigured:		// 
																									HMIData.baggerInhibited.active := FALSE;
																										 
															AuxInputSelection.BaggerInhibit:		//
																 									HMIData.baggerInhibited.active := iAuxConfigInput;
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
 
CASE HMIData.fillerFactorySelection OF
	FillerSelection.NotInstalled:					// No filler
		 											filler.enable := FALSE;
													filler.activateFiller := FALSE;	
													fillerModeCycleStartOnlyPulse.Reset();
		 
	FillerSelection.StandardFiller:					// Only enable filler if Aux IO is enabled
		 											filler.enable := (HMIData.auxIOConfig.factorySelection = AuxiliaryIOSelection.AuxIOStandard);
		 											
														
		 
END_CASE 
fillerModeCycleStartOnlyPulse.DwellSetting := 4000;
fillerModeCycleStartOnlyPulse(Q => HMIData.fillerModeCycleStartOnly.active);
filler(
	enable:= , 
	fillerTrigger:= iAuxFillerTrigger,
	fillerOK:= iAuxFillerOK, 
	activateFiller:= , 
	dropTime:= HMIData.fillerDropTime,
	state=> , 
	fillerModeActive=> , 
	waitingForFiller=> ,
	cycleBagRequest=> , 
	cycleBaggerToActivateFiller=> , 
	notReady=> );	 
IF filler.activateFiller AND NOT filler.cycleBaggerToActivateFiller.active THEN
	IF HMIData.initiateCycle OR startCycleReqFromPalmButtons THEN
		fillerModeCycleStartOnlyPulse.Trigger();
	END_IF
END_IF
	 

//HMIData.packageEjectGuardRemoved.active :=  HMIData.packageEjectSelection = PackageEjectionSelection.LabelSideUp AND NOT iPackageEjectGuardClosed;
HMIData.loadPlateService.extendedFeedback := HMIData.rearLoadPlateService.extendedFeedback := iLoadPlateExtended;
HMIData.loadPlateService.retractedFeedback := HMIData.rearLoadPlateService.retractedFeedback := iLoadPlateRetracted;

rearLoadPlateRetract();
oLoadPlateRetract := rearLoadPlateRetract.Q;
oLoadPlateExtend := NOT oLoadPlateRetract;
loadPlateFaultTimer(
	enable:= , 
	extendCommand:= oLoadPlateExtend, 
	extendedInput:= iLoadPlateExtended, 
	retractCommand:= oLoadPlateRetract, 
	retractedInput:= iLoadPlateRetracted, 
	faultTime:= , 
	failToExtend=> loadPlateFaults.failedToLoad.faultTrigger, 
	failToRetract=> loadPlateFaults.failedToDischarge.faultTrigger);
rearLoadPlateFaultTimer(
	enable:= , 
	extendCommand:= oLoadPlateExtend, 
	extendedInput:= iLoadPlateExtended, 
	retractCommand:= oLoadPlateRetract, 
	retractedInput:= iLoadPlateRetracted, 
	faultTime:= , 
	failToExtend=> rearLoadPlateFaults.failedToLoad.faultTrigger, 
	failToRetract=> rearLoadPlateFaults.failedToDischarge.faultTrigger);

HMIData.forwardLoadPlateService.extendedFeedback := iFrontLoadPlateExtended;
HMIData.forwardLoadPlateService.retractedFeedback := iFrontLoadPlateRetracted;
forwardLoadPlateRetract.DwellSetting := TO_UINT(HMIData.loadPlateDwell * 1000);
forwardLoadPlateRetract.DelaySetting := TO_UINT(HMIData.loadPlateDelay * 1000);
forwardLoadPlateRetract();
oFrontLoadPlateToLoad := NOT forwardLoadPlateRetract.Q;
oFrontLoadPlateToDischarge := NOT oFrontLoadPlateToLoad;
forwardLoadPlateFaultTimer(
	enable:= , 
	extendCommand:= NOT oFrontLoadPlateToLoad, 
	extendedInput:=iFrontLoadPlateExtended, 
	retractCommand:= oFrontLoadPlateToLoad, 
	retractedInput:= iFrontLoadPlateRetracted, 
	faultTime:= , 
	failToExtend=> forwardLoadPlateFaults.failedToLoad.faultTrigger, 
	failToRetract=> forwardLoadPlateFaults.failedToDischarge.faultTrigger);
		 
HMIData.loadShelfService.extendedFeedback := iLoadShelfExtended;
HMIData.loadShelfService.retractedFeedback := iLoadShelfRetracted;
loadShelfExtend.DwellSetting := TO_UINT(HMIData.loadPlateDwell * 1000);
loadShelfExtend.DelaySetting := TO_UINT(HMIData.loadPlateDelay * 1000);
loadShelfExtend();
oLoadShelfUp := NOT loadShelfExtend.Q;
loadShelfFaultTimer(
	enable:= , 
	extendCommand:= NOT oLoadShelfUp, 
	extendedInput:=iLoadShelfExtended, 
	retractCommand:= oLoadShelfUp, 
	retractedInput:= iLoadShelfRetracted, 
	faultTime:= , 
	failToExtend=> loadShelfFaults.failedToDischarge.faultTrigger, 
	failToRetract=> loadShelfFaults.failedToLoad.faultTrigger);
 
exitConveyorRun();
exitConveyorRun.DwellSetting := TO_UINT(HMIData.exitConveyorDwell * 1000);
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

	 
IBDMotor(ptrEIPInputs := ADR(iIBDMotorEIP),
                ptrEIPOutputs := ADR(oIBDMotorEIP),
                stepsPerInchSetpoint := Globals.STEPS_PER_INCH_TFBelt,
                //faultHandler := PRG_Bagger.faultHandler,
				reversePolarity := FALSE,
				defaultCurrentSetpoint := 650,
				//commFail := IBD_Motor.eState <> IoDrvEthernetIP.AdapterState.RUNNING,
				commFail := IBD_Motor.eState <> IoDrvEthernetIP.AdapterState.RUNNING,
				isHomable := TRUE);			
IBDMotor.Execute();

IF HMIData.passthroughSetting + IBDOffset > 12.0 THEN
	 IBDOutSetting := 12.0;
ELSE
	IBDOutSetting := HMIData.passthroughSetting + IBDOffset;
END_IF
		  
IBD(
	enable:= , 
	pbarOutSetting:= IBDOutSetting, 
	pbarInSetting:= , 
	disableFaults:= , 
	extendCommand:= HMIData.IBDService.extendCommand, 
	retractCommand:= HMIData.IBDService.retractCommand , 
	failToClose=> , 
	failToOpen=> , 
	state=> , 
	actualPosition=> , 
	IBDOpen=> , 
	homeRequired=> , 
	clamped=> , 
	IBDMotor:= IBDMotor);

obstructionFaultONS(CLK := pressureBar.faults.obstructionDetected.active);
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
					AND NOT pressureBarMotor.faults.commFail.active;

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
	
	HMIData.ackAllFaults := TRUE;
	enable := TRUE;
	
	bagDropTimer.IN := FALSE;
	
	motorizedSealFlattenersMode := DEVICE_MODES.Auto;
	motorizedSealFlatteners.Reset();
	motorizedSealFlatteners.enable := HMIData.sealFlattenersSelection = SealFlattenerSelection.MotorizedSealFlatteners;
	
	
	HMIData.bagOpenFeedNewBagCount := 0;
	bagOpenRetryCount := 0;
	
	HMIData.stopMachine := FALSE;
	
	electricPressureBarMode := DEVICE_MODES.Auto;
	
	pressureBar.enable := TRUE;
	//pressureBar.ExtendCylinderLowPressure();
	
	//HMIData.sealBarTemperatureSetting := 300;
	enableHeater := TRUE;
	
	bagDeliveryMode := DEVICE_MODES.Auto;
	bagDelivery.Reset();
	bagDelivery.enable := TRUE;
	//bagDelivery.bagFeedMasterMotor.SetRearMotorToTorqueMode();
	IF iPowerOffButtonONS.OSR THEN
		bagDelivery.AutoFeedToEye();
	END_IF
	bagOpened := FALSE;
	
	enableBatch := FALSE;
	batchCount := 0;
	
	//zebraPrinter.autoSendLabel := TRUE;
	printerMode := DEVICE_MODES.Auto;
	zebraPrinter.Reset();
	//zebraPrinter.enable := TRUE;
	
	IF iPowerOffButtonONS.OSR AND NOT bagDelivery.bagTensionFault.active THEN
		IF (HMIData.factoryTestMode AND (HMIData.bagsMade.count < 1000)) THEN
			HMIData.bagsMade.Clear();
		END_IF 
	END_IF  
	
	//passthrough.Reset();
	pressureBarMotor.Reset();
	passthroughMode := DEVICE_MODES.Auto;
	//passthrough.enable := TRUE;
	
	oVacOn := FALSE;
	rearLoadPlateRetract.Reset();
	forwardLoadPlateRetract.Reset();
	loadShelfExtend.Reset();
	
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
	state := HEAD_STATES.Idle;
	
	setPassthroughPB := FALSE;
	//homeJawPB := FALSE;
	HMIData.jobLoadRequired.active := TRUE;
	HMIData.makeReady := FALSE;
	bagDelivery.bagFeedRearMotor.SetRearMotorTorqueValue(TO_DINT(HMIDAta.bagTensionSetting * 100));
	hmiLight.TurnOff();
ELSE
	Cube67_BN_E_V2.xAcknowledge := FALSE;
	FestoManifold.xAcknowledge := FALSE;
	MSFMotor.xAcknowledge := FALSE;
	Bag_Delivery_EIP_Motor.xAcknowledge := FALSE;
	Pbar_ServoEIP.xAcknowledge := FALSE;
	Bag_Delivery_Rear_Motor.xAcknowledge := FALSE;
	Keyence_BCV.xAcknowledge := FALSE;
	IBD_MOtor.xAcknowledge := FALSE;
END_IF


IF enableONS.Q OR resetONS.Q THEN
    state := HEAD_STATES.Idle;
	sealAndSeparateSubState := SEAL_SEPARATE_STATES.Idle;
	releaseAndFeedSubState := RELEASE_FEED_STATES.Idle;
	openBagSubState := BAG_OPEN_ASSIST_STATES.Idle;
	finishCycleSubState := FINISH_CYCLE_STATES.Idle;
	motorizedSealFlatteners.Reset();
	pressureBar.Reset();
	IBD.Reset();
	bagDelivery.Reset();
	zebraPrinter.Reset();
	homeJawPB := FALSE;
	IF IBD.homeRequired THEN
		homeJawPB := TRUE;
	ELSE
		//IBD.OpenIBD();
		homeJawPB := TRUE;
	END_IF
	IF pressureBar.homeRequired THEN
		homeJawPB := TRUE;
	ELSE
		//pressureBar.OpenJaw();
		homeJawPB := TRUE;
	END_IF
	//pressureBar.ExtendCylinderLowPressure();
	bagDropTimer.IN := FALSE;
	_reset := FALSE;
	cycleTimer.IN := FALSE;
//	bagFailedToOpen := FALSE;
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
IF Globals.enableDryCycle THEN
    zebraPrinter.enable := FALSE;
END_IF

// Send torque value to motor                 
rearMotorCommsReturned(CLK := bagDelivery.bagFeedRearMotor.commFail);
IF HMIData.jobLoaded OR rearMotorCommsReturned.Q THEN
	bagDelivery.bagFeedRearMotor.SetRearMotorTorqueValue((TO_DINT(HMIData.bagTensionSetting * 100)));
END_IF

// Clear batch count on batch enable
enableBatchONS(CLK := enableBatch);
IF enableBatchONS.Q THEN
    batchCount := 0;
END_IF

//IF NOT enable OR NOT readyToRun OR faultONS.OSR THEN
IF NOT enable OR faultONS.OSR THEN
    state := HEAD_STATES.Fault;
	enableBatch := FALSE;
	//pressureBarMotor.Stop();
	cycleTimer.IN := FALSE;
END_IF
pressureBarCloseDelay(PT := TO_TIME(HMIData.pressureBarCloseDelay * 1000));
cycleTimer();

footSwitchONS(CLK := iFootSwitch);

IF state <> HEAD_STATES.Idle AND HMIData.initiateCycle THEN
	HMIData.initiateCycle := FALSE;
END_IF
CASE state OF
    HEAD_STATES.Idle :                                // Start cycle if enabled
													
													
                                                    IF (startCycle AND (filler.cycleBaggerToActivateFiller.active OR NOT filler.activateFiller)
													OR (enableBatch AND (batchCount < batchSetting))
													OR (HMIData.factoryTestMode AND (HMIData.bagsMade.count < 1000)) AND factoryTestModeKeepCycling AND NOT LPA.Q
													OR startCycleReqFromPalmButtonsONS.OSR AND (filler.cycleBaggerToActivateFiller.active OR NOT filler.activateFiller)
													OR (HMIData.initiateCycle AND readyToRun) AND (filler.cycleBaggerToActivateFiller.active OR NOT filler.activateFiller)
													OR filler.cycleBagRequest) 
													OR footSwitchONS.OSR
													AND NOT HMIData.faultActive 
													AND NOT HMIData.stopMachine 
													AND NOT HMIData.baggerInhibited.active
													AND NOT HMIData.sealBarNotAtTemperature.active
													AND NOT setPassthroughPB THEN
                                                        state := HEAD_STATES.SealAndSeparateBag;
                                                        startCycle := FALSE;
														
														cycleTimer.IN := TRUE;
                                                    END_IF
													IF NOT Globals.passthroughChangedFromJog AND HMIData.jobLoaded THEN
														HMIData.jobLoaded := FALSE;
													END_IF
                                                    IF (HMIData.passthroughSetting <> passthroughSettingLast) OR (Globals.passthroughChangedFromJog AND HMIData.jobLoaded) AND NOT pressureBarMotor.Faulted AND NOT pressureBarMotor.HomeRequired THEN
															setPassthroughPB := TRUE;
															Globals.passthroughChangedFromJog := FALSE;
															HMIData.jobLoaded := FALSE;
															passthroughSetting := HMIData.passthroughSetting;
															passthroughSettingLast := HMIData.passthroughSetting;
													END_IF
													
													IF (NOT pressureBarMotor.HomeRequired OR pressureBarMotor.Faulted)
														AND (NOT motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.homeRequiredIndication OR motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.Faulted)
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
														hmiLight.TurnOff();
													END_IF
													
													IF HMIData.sealBarNotAtTemperature.active THEN
														factoryTestModeKeepCycling := FALSE;
													END_IF
													
													IF bagOpened THEN
														IF NOT bagOpenFingers.CheckIfBagGrabbed(FALSE) THEN
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
														rearLoadPlateRetract.ManualOn();
														HMIData.loadPlateService.retractCommand := FALSE;
														HMIData.rearLoadPlateService.retractCommand := FALSE;
													END_IF                                      
                                                    
													IF HMIData.loadPlateService.extendCommand OR HMIData.rearLoadPlateService.extendCommand THEN
														rearLoadPlateRetract.ManualOff();
														HMIData.loadPlateService.extendCommand := FALSE;
														HMIData.rearLoadPlateService.extendCommand := FALSE;
													END_IF
													
													IF HMIData.loadShelfService.retractCommand THEN
														loadShelfExtend.ManualOn();
														HMIData.loadShelfService.retractCommand := FALSE;
													END_IF                                      
                                                    
													IF HMIData.loadShelfService.extendCommand THEN
														loadShelfExtend.ManualOff();
														HMIData.loadShelfService.extendCommand := FALSE;
													END_IF	

													IF HMIData.forwardLoadPlateService.retractCommand THEN
														forwardLoadPlateRetract.ManualOn();
														HMIData.forwardLoadPlateService.retractCommand := FALSE;
													END_IF                                      
                                                    
													IF HMIData.forwardLoadPlateService.extendCommand THEN
														forwardLoadPlateRetract.ManualOff();
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
														funnel.OpenNow();
														HMIData.funnelService.retractCommand := FALSE;
													END_IF                                      
                                                    
													IF HMIData.funnelService.extendCommand THEN
														funnel.CloseNow();
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
													IF enableIBDDeflate THEN
														sealAndSeparateSubState := SEAL_SEPARATE_STATES.BringInIBD;
													ELSE
														sealAndSeparateSubState := SEAL_SEPARATE_STATES.WaitForJawCloseDelay;
													END_IF
													filler.BaggerCycleInitiated();
                                                    HMIData.inCycle := TRUE;
													HMIData.airFilterClean.Increment();
													HMIData.baggerCycles.Increment();
													IF funnel.enable THEN
														funnel.CloseNow();
													END_IF
													
                                                    state := HEAD_STATES.SealingAndSeparatingBag;
                                                    
                
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
                                                    {warning 'TODO: change this counting logic to account for MSF'}
                                                    IF enableBatch THEN
                                                        batchCount := batchCount + 1;
                                                    END_IF
  
                                                    IF Globals.enableDryCycle THEN
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
														 AND pressureBar.state = PRESSURE_BAR_STATES.Idle THEN
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
											filler.BaggerCycledAndReady();
											cycleTime := (TIME_TO_REAL(cycleTimer.ET) / 1000); 
											cycleTimer.IN := FALSE;
											IF HMIData.averageCycleTime = 0 THEN
												HMIData.averageCycleTime := cycleTime;
											ELSE
												HMIData.averageCycleTime := (cycleTime + HMIData.averageCycleTime) / 2;
											END_IF
											HMIData.inCycle := FALSE;
											//bagFailedToOpen := FALSE;
											IF HMIData.factoryTestMode AND NOT HMIData.stopMachine THEN
												IF (HMIData.bagsMade.count >= 1000) THEN
													factoryTestModeKeepCycling := FALSE;
													HMIData.factoryTestMode := FALSE;
												ELSE
													factoryTestModeKeepCycling := TRUE;
												END_IF
											END_IF	
	HEAD_STATES.StartReset 	:			// Reset all 
	
	HEAD_STATES.Resetting : 

										
    HEAD_STATES.StartHoming :            // 
											IF allMotorCommsGood THEN
												motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.faults.notHomed.Ack();
												IF pressureBar.homeRequired THEN
													pressureBar.HomeNow();
												ELSE
													pressureBar.OpenJaw();
												END_IF
												IF IBD.homeRequired THEN
													IF NOT enableLabelSideUp THEN
														rearLoadPlateRetract.ManualOn();
													END_IF
													IBD.HomeNow();
												ELSE
													IBD.OpenIBD();
												END_IF
												
                                            	state := HEAD_STATES.Homing; 
											END_IF
                                                                                   
    
    HEAD_STATES.Homing :                // 
                                            //IF NOT pressureBar.homeRequired AND (NOT IBD.homeRequired OR NOT IBD.enable) THEN
											IF pressureBar.pressureBarOpen AND (NOT IBD.homeRequired OR NOT IBD.enable) THEN
                                                state := HEAD_STATES.HomingComplete;
												rearLoadPlateRetract.ManualOff();   
												IF motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.HomeRequired AND HMIData.sealFlattenersSelection = SealFlattenerSelection.MotorizedSealFlatteners THEN
													motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.HomeNow();
													motorizedSealFlatteners.sealFlattenersVerticalAxis.Retract();
												END_IF    
                                            END_IF
                                            
    HEAD_STATES.HomingComplete :        // 
											IF NOT motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.HomeRequired THEN
												 homeJawPB := FALSE;
												state := HEAD_STATES.Idle;
												//HMIData.passthroughSetting := 6.0;
												setPassthroughPB := TRUE;
											END_IF
                                           
    
    HEAD_STATES.MovePassthrough :        // 
                                            pressureBar.OpenJaw();
											IBD.OpenIBD();
                                            state := HEAD_STATES.MovingPassthrough;
    
    HEAD_STATES.MovingPassthrough :    		IF pressureBar.pressureBarOpen AND IBD.IBDOpen THEN
                                                state := HEAD_STATES.MovedPassthrough;     
                                            END_IF
                                            
    HEAD_STATES.MovedPassthrough :        // 
                                            //pressureBar.AutoDoneMovingPassthrough();
                                            state := HEAD_STATES.Idle;
											setPassthroughPB := FALSE;
                                                    
    HEAD_STATES.Fault :                     hmiLight.TurnOff();
											HMIData.inCycle := FALSE;
											cycleTimer.IN := FALSE;
											bagDelivery.bagFeedMasterMotor.SetRearMotorToEncoderFollowing();
											sealAndSeparateSubState := SEAL_SEPARATE_STATES.Idle;
											releaseAndFeedSubState := RELEASE_FEED_STATES.Idle;
											openBagSubState := BAG_OPEN_ASSIST_STATES.Idle;
											finishCycleSubState := FINISH_CYCLE_STATES.Idle;
											oVacOn := FALSE;
											filler.Reset();
											LPA.ManualOff();
											//IBD.Reset();
											exitConveyorRun.Reset();
											externalExitConveyorRun.Reset();
											oRunPrinterRibbonUnwindMotor := FALSE;
											setPassthroughPB := FALSE;
											homeJawPB := FALSE;
											startCycle := FALSE;
											HMIData.initiateCycle := FALSE;
											factoryTestModeKeepCycling := FALSE;
											pressureBarCloseDelay.IN := FALSE;
											//bagOpened := FALSE;
                                                    
END_CASE

CASE sealAndSeparateSubState OF
    SEAL_SEPARATE_STATES.Idle : 
	
	SEAL_SEPARATE_STATES.BringInIBD : 				// Bring in IBD if enabled
													IF enableIBDDeflate THEN
														IBD.CloseIBD();
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
                                                    
													pressureBar.CloseJaw();
                                                    sealAndSeparateSubState := SEAL_SEPARATE_STATES.MovingJawIn;
                                                    
                                                    
                                                    
                                                    
                                                    
    SEAL_SEPARATE_STATES.MovingJawIn :                // If Jaw is in and flatteners out then move on
                                                    IF (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersOut OR NOT motorizedSealFlatteners.enable) 
                                                        AND (pressureBar.clamped OR NOT pressureBar.enable)
                                                        THEN
                                                            sealAndSeparateSubState := SEAL_SEPARATE_STATES.MovedJawIn;    
                                                    END_IF
                                                                
    SEAL_SEPARATE_STATES.MovedJawIn :                // Will add sealing logic here
                                                    sealAndSeparateSubState := SEAL_SEPARATE_STATES.ReverseBag;
                                                    
    SEAL_SEPARATE_STATES.ReverseBag :                // Reverse bag if bag delivery enabled, otherwise open jaw
													//IBD.OpenFull();
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
                                                        AND (pressureBar.clamped OR NOT pressureBar.enable)
                                                        AND (bagDelivery.state = BAG_DELIVERY_STATES.ReverseDone OR NOT bagDelivery.enable)
														AND (sealTimer.Q OR HMIData.separateBeforeSeal)
                                                        THEN
															IF NOT HMIData.separateBeforeSeal THEN
																HMIData.sealBarCycles.Increment();
															END_IF
															
															sealTimer.IN := FALSE;
                                                            sealAndSeparateSubState := SEAL_SEPARATE_STATES.Reversedbag;
                                                    END_IF
    SEAL_SEPARATE_STATES.Reversedbag :                // 
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
													
																				
                                                    
    SEAL_SEPARATE_STATES.Done :                        // 
                                                    
                                    
    SEAL_SEPARATE_STATES.Fault :
END_CASE


CASE releaseAndFeedSubState OF
    RELEASE_FEED_STATES.Idle :                        //
                                                        
    RELEASE_FEED_STATES.MoveJawOutAndDropBag :        // 
                                                    IF (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersOut OR NOT motorizedSealFlatteners.enable) 
                                                        AND (pressureBar.clamped OR NOT pressureBar.enable)
                                                        AND ((bagDelivery.state = BAG_DELIVERY_STATES.ReverseDone) OR Globals.enableDryCycle)
                                                        OR (bagDelivery.state =  BAG_DELIVERY_STATES.WaitingForPrinter AND zebraPrinter.enable)
                                                        OR NOT bagDelivery.enable
                                                        THEN
                                                            IF motorizedSealFlatteners.enable THEN
                                                                motorizedSealFlatteners.AutoMoveToClearance();
                                                            END_IF
                                                            
                                                            IF pressureBar.enable THEN
                                                                pressureBar.OpenJaw();
                                                            END_IF
                                                            //IBD.OpenFull();
// 															IF enableBagOpen THEN
// 																bagOpenFingers.Release();
// 															END_IF
															
															IF enableIBDEject THEN
																IBD.CloseIBD();
															END_IF
															
															IF enableLoadPlate THEN
																rearLoadPlateRetract.Trigger();
															END_IF
															
															IF TO_DINT(HMIData.exitConveyorDwell) <> 0 THEN
																exitConveyorRun.Trigger();
															END_IF
															
															IF TO_DINT(HMIData.externalExitConveyorDwell) <> 0 THEN
																externalExitConveyorRun.Trigger();
															END_IF
															
															IF enableLabelSideUp THEN
																forwardLoadPlateRetract.Trigger();
																loadShelfExtend.Trigger();
															END_IF
															
															IF HMIData.lpaBagEjectAssistEnable THEN
																LPA.ManualOn();
															END_IF
															IBD.OpenFull();
                                                           bagDropTimer.IN := TRUE;
														   releaseAndFeedSubState := RELEASE_FEED_STATES.MovingJawOutAndDroppingBag;
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
															
															IF bagDelivery.enable AND NOT zebraPrinter.enable THEN
                                                                bagDelivery.AutoFeedBagOut();
																LPA.ManualOff();
																IF HMIData.lpaDuringBagFeedEnable THEN
																	LPA.ManualOn();
																END_IF
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
                                                        releaseAndFeedSubState := RELEASE_FEED_STATES.FeedToOffset;
                                                    END_IF
                                                    
    RELEASE_FEED_STATES.FeedToOffset :              // This starts feeding to the print offset
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
													IF HMIData.lpaDuringBagFeedEnable THEN
														LPA.ManualOn();
													END_IF
													
                                                    releaseAndFeedSubState := RELEASE_FEED_STATES.MovingJawOutAndFeedingBag;
                                                                                
                                                                                                            
    RELEASE_FEED_STATES.MovingJawOutAndFeedingBag :    // 
    
													
													IF (bagdelivery.state = BAG_DELIVERY_STATES.Ready OR NOT bagdelivery.enable)
                                                        AND (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersToBagFeed OR NOT motorizedSealFlatteners.enable) 
                                                        AND (pressureBar.pressureBarOpen OR NOT pressureBar.enable)
                                                        THEN
															IF LPA.DwellSetting = 0 THEN
																LPA.ManualOff();
															END_IF
															//IBD.OpenIBD();
                                                            releaseAndFeedSubState := RELEASE_FEED_STATES.MovedJawOutAndFedBag;
                                                    END_IF
                                                    
    RELEASE_FEED_STATES.MovedJawOutAndFedBag :      // Wait until bag is fed out before triggering barcode fail.
													IF barcodeVerifier.barcodeFault THEN
														barcodeVerificationFailed.Trigger();
													END_IF 
													
													IF enableIBDDeflate OR enableIBDEject THEN
														IBD.OpenIBD();
													END_IF
													releaseAndFeedSubState := RELEASE_FEED_STATES.Done;
    RELEASE_FEED_STATES.Done :
    RELEASE_FEED_STATES.Fault :
END_CASE

CASE openBagSubState OF
    BAG_OPEN_ASSIST_STATES.Idle :                    // 
                                                    
                                                    
                                                    
    BAG_OPEN_ASSIST_STATES.MoveJawIn :                // Close jaw against bag. In the future we may also start vacuum here
                                                    pressureBar.CloseJawNoLatch();
													(*HPA.DwellSetting := 80;
													HPA.Trigger();*)
													IF HPA.DwellSetting <> 0 THEN
														HPA.Trigger();	
													END_IF
													
													//oVacOn := TRUE; // Hard coded for now, this is vacuum
                                                    openBagSubState := BAG_OPEN_ASSIST_STATES.MovingJawIn;        
                                                    
                                                    
    BAG_OPEN_ASSIST_STATES.MovingJawIn :            // Move on once jaw is closed
                                                    IF pressureBar.iPressureBarClosed OR NOT pressureBar.enable THEN
                                                        openBagSubState := BAG_OPEN_ASSIST_STATES.MovedJawIn;        
                                                    END_IF
                                                    
                                                    
    BAG_OPEN_ASSIST_STATES.MovedJawIn :                // Hold onto the bag with vacuum to build suction
                                                    vacuumHoldTimer.IN := TRUE;
													oVacOn := TRUE; // Hard coded for now, this is vacuum
													IF vacuumHoldTimer.Q THEN
														openBagSubState := BAG_OPEN_ASSIST_STATES.MoveJawOut; 
														vacuumHoldTimer.IN := FALSE;
													END_IF
                                                                   
                                                    
                                                    
    BAG_OPEN_ASSIST_STATES.MoveJawOut :                // Open the jaw and move seal flatteners in and to bag holding
                                                    pressureBar.OpenJaw();
													motorizedSealFlatteners.AutoMoveIn();
                                                    openBagSubState := BAG_OPEN_ASSIST_STATES.MovingJawOutAndGrab;
                                                    
                                                    
    BAG_OPEN_ASSIST_STATES.MovingJawOutAndGrab :    // Once everything that is enabled is homed finish cycle 
													bagOpenFingerDelay.IN := TRUE;
													IF bagOpenFingerDelay.Q THEN
														bagOpenFingers.Grab();
														bagOpenFingerDelay.IN := FALSE;

														openBagSubState := BAG_OPEN_ASSIST_STATES.CheckForSuccessfulBagGrab;
													END_IF
													  

	BAG_OPEN_ASSIST_STATES.CheckForSuccessfulBagGrab : 	//
														IF bagOpenRetryCount < bagOpenRetrySetting THEN
															bagOpenCheckDelay.IN := TRUE;
															IF bagOpenCheckDelay.Q THEN
																IF bagOpenFingers.CheckIfBagGrabbed(TRUE) THEN // This method checks to see if the bag is grabbed and returns true if so.
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
														IF (pressureBar.pressureBarOpen OR NOT pressureBar.enable) 
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
																finishCycleSubState := FINISH_CYCLE_STATES.Done;
															ELSE
																IF motorizedSealFlatteners.enable THEN
																	finishCycleSubState := FINISH_CYCLE_STATES.BringSealFlattenersInAndDown;
																ELSE
																	finishCycleSubState := FINISH_CYCLE_STATES.Done;
																END_IF
															END_IF
															IF LPA.DwellSetting <> 0 THEN
																LPA.Trigger();
															END_IF
	
	FINISH_CYCLE_STATES.OpenFunnel :						//
															IF LPA.DwellSetting <> 0 THEN
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
																	finishCycleSubState := FINISH_CYCLE_STATES.Done;
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
																		finishCycleSubState := FINISH_CYCLE_STATES.Done;
																	END_IF
																END_IF
															ELSE
																IF motorizedSealFlatteners.enable THEN
																	finishCycleSubState := FINISH_CYCLE_STATES.BringSealFlattenersToBagHolding;
																ELSE
																	finishCycleSubState := FINISH_CYCLE_STATES.Done;
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
															finishCycleSubState := FINISH_CYCLE_STATES.Done;
	
	FINISH_CYCLE_STATES.BringSealFlattenersToBagHolding:	//
															motorizedSealFlatteners.AutoMoveToBagHolding();
															finishCycleSubState := FINISH_CYCLE_STATES.BringingSealFlattenersToBagHolding;
	
	FINISH_CYCLE_STATES.BringingSealFlattenersToBagHolding: //
															IF motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.Idle THEN
																finishCycleSubState := FINISH_CYCLE_STATES.SealFlattenersAtBagHolding;
															END_IF
																
	FINISH_CYCLE_STATES.SealFlattenersAtBagHolding : 		//
															finishCycleSubState := FINISH_CYCLE_STATES.Done;
	
	FINISH_CYCLE_STATES.Done :								//
															bagOpenRetryCount := 0;
														
	
	FINISH_CYCLE_STATES.Fault :
	
	
END_CASE
HMIData.initiateCycle := FALSE;