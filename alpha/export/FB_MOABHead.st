

FUNCTION_BLOCK FB_MOABHead EXTENDS BaseComponentFB
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
END_VAR
VAR
    motorizedSealFlatteners : MotorizedSealFlattenersFB_BagFeed();
	msfVerticalAxis : FB_ThreePositionCylinder();
    pressureBar : PneumaticPressureBarFB_1();
	sealBarTempSensor : FB_IFMTempSensor();
	sealBarHeater : FB_TempController();
    startCycleONS : R_TRIG;
	enableBagOpen : BOOL;
	enableLoadPlate : BOOL;
	enableHeater : BOOL;
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
	exitConveyorRun : MonostableMultivibratorFB() := (Dwellsetting := 6000);
	bagOpenFingers : BagOpenFingersWithSensorsFB();
	bagOpenCheckDelay : Standard.TON := (PT:= T#400MS); // Delay to check if bag open
	bagOpenRetrySetting : UINT;		// Number of times to retry opening bag
	bagOpenRetryCount : UINT;		// Count of current retry attempts
	bagOpenFeedNewBagSetting : UINT; // Number of new bags to try
	bagOpenFeedNewBagCount : UINT;	// Count of new bags tried in recovery
	recoveryModeActive : BOOL; 		// Recovery Mode Active
	pressureBarEndStopMotor : FB_AppliedMotionStepServoEIPPassthrough();
	passthrough : AdjustablePassthroughFB();
	homeJawPB : BOOL;
    setPassthroughPB : BOOL;
	vacuumHoldTimer : Standard.TON() := (PT := T#250MS);
	cycleTimer : TON() := (PT := T#1000S);
	cycleTime : REAL;
	bagFailedToOpen : FB_Fault(name := 'Bag Failed to Open');
	safePowerFailure : FB_Fault(name := 'E-Stop/Safety Power Failure');
	packageEjectGuardRemoved : FB_Fault(name := 'Package Eject Guard Removed');
	iPowerOffButtonONS : FB_ONS();
	loadPlateFaultTimer : FB_CylinderFaults();
	loadPlateFaults : LoadPlateFaultsType;
	forwardLoadPlateFaultTimer : FB_CylinderFaults();
	forwardLoadPlateFaults : LoadPlateFaultsType;
	rearLoadPlateFaultTimer : FB_CylinderFaults();
	rearLoadPlateFaults : LoadPlateFaultsType;
	loadShelfFaultTimer : FB_CylinderFaults();
	loadShelfFaults : LoadPlateFaultsType;
	LPA : MonostableMultivibratorFB();
	hpaServiceOnONS : FB_ONS;
	exitConveyorJogONS : FB_ONS;
	hmiLight  : FB_HMILight;
	faultONS : FB_ONS;
	powerSettlingTimer : Standard.TON := (PT := T#6S);
END_VAR

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
safePowerFailure.faultTrigger := NOT iEStopOK;

// Option setup and factory config  
  
HMIData.lastCycleTime := cycleTime;
HMIData.averageCycleTime := cycleTime + 0.31;
HMIData.printerNotReady.active := NOT printerReady AND zebraPrinter.enable;
HMIData.waitingForPrinter.active := zebraPrinter.state = PRINTER_STATES.WaitingForData AND releaseAndFeedSubState = RELEASE_FEED_STATES.WaitForPrinter;
//HMIData.printerRibbonLow.active := printerRibbonLow;


	 
batchSetting := HMIData.batchSetting;	
HMIData.batchCount := batchCount;

bagOpenRetrySetting := HMIData.bagOpenRetrySetting;
HMIData.bagOpenRetryCount := bagOpenRetryCount;
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

// Setup of MOAB Machine Pressure bar ("#2") on actual machine, not test rig
pressureBar(iPressureBarExtended := iPressureBarExtended, 
			iPressureBarRetracted := iPressureBarRetracted, 
			iPressureBarNotObstructed := iPressureBarNotObstructed, 
			oExtendCylinder => oPBar1Extend, oRetractCylinder => oPBar1Retract,
			cumulativeHeadCycleCount := Globals.headCycleCount2);
pressureBar.Mode := electricPressureBarMode;
//Adding extra pressure bar valve for test
opBar2Extend := oPBar1Extend;
opbar2Retract := oPBar1Retract;


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

// Setup of pick and place motors


sealBarTempSensor(ptrTemperatureBytes := ADR(iHeaterBarTempInputs));
sealBarTempSensor.Execute();
sealBarHeater(enable := NOT HMIData.faultActive,
				temperatureSensor := sealBarTempSensor,
				temperatureSetpoint := HMIData.sealBarTemperatureSetting,
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
	 
LPA.DwellSetting := TO_UINT(HMIData.lpaDwell * 1000);
LPA(Q => oLPAOn);
	 
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
	
	PackageEjectionSelection.LabelSideUp:				// Enable all
		 												enableLoadPlate := TRUE;
														enableLabelSideUp := TRUE;	
														loadPlateFaultTimer.enable := FALSE;
														forwardLoadPlateFaultTimer.enable := Globals.machinePowerOK;
														rearLoadPlateFaultTimer.enable := Globals.machinePowerOK;
														loadShelfFaultTimer.enable := Globals.machinePowerOK;
END_CASE


HMIData.packageEjectGuardRemoved.active :=  HMIData.packageEjectSelection = PackageEjectionSelection.LabelSideUp AND NOT iPackageEjectGuardClosed;
HMIData.loadPlateService.extendedFeedback := HMIData.rearLoadPlateService.extendedFeedback := iLoadPlateExtended;
HMIData.loadPlateService.retractedFeedback := HMIData.rearLoadPlateService.retractedFeedback := iLoadPlateRetracted;
rearLoadPlateRetract.DwellSetting := TO_UINT(HMIData.loadPlateDwell * 1000);
rearLoadPlateRetract.DelaySetting := TO_UINT(HMIData.loadPlateDelay * 1000);
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
		  
bagOpenFingers(releaseOutput => oBOFUp,
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
                faultHandler := PRG_Bagger.faultHandler,
				reversePolarity := TRUE,
				defaultCurrentSetpoint := 650,
				commFail := Pbar_ServoEIP.udiState <> 4,
				isHomable := TRUE);			
pressureBarEndStopMotor.Execute();

passthrough(pressureBarEndStopMotor := pressureBarEndStopMotor, 
			cumulativeChangeCount := Globals.passthroughChangeCount2, 
			cumulativeChangeDistance := Globals.passthroughChangeDistance2,
			jogInPB := HMIData.jogPassthroughForward,
			jogOutPB := HMIData.jogPassthroughReverse);
passthrough.Mode := passthroughMode;


{endregion}
	 
hmiLight(lightOutput => oHMILight);
faultONS(CLK := HMIData.faultActive);

readyToRun := (motorizedSealFlatteners.Ready OR NOT motorizedSealFlatteners.enable) 
                AND (pressureBar.Ready OR NOT pressureBar.enable)
                AND (bagDelivery.Ready OR NOT bagDelivery.enable)
                AND (zebraPrinter.Ready OR NOT zebraPrinter.enable)
				AND (passthrough.Ready OR NOT passthrough.enable);
iPowerOffButtonONS(CLK := iPowerOffButton);

				
IF HMIData.makeReady OR iPowerOffButton THEN
	HMIData.ackAllFaults := TRUE;
	enable := TRUE;
	
	bagDropTimer.IN := FALSE;
	
	motorizedSealFlattenersMode := DEVICE_MODES.Auto;
	motorizedSealFlatteners.Reset();
	motorizedSealFlatteners.enable := TRUE;
	IF motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.HomeRequired THEN
		motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.HomeNow();
		motorizedSealFlatteners.sealFlattenersVerticalAxis.Retract();
	END_IF
	
	
	
	HMIData.stopMachine := FALSE;
	
	electricPressureBarMode := DEVICE_MODES.Auto;
	pressureBar.Reset();
	pressureBar.enable := TRUE;
	//pressureBar.ExtendCylinderLowPressure();
	
	//HMIData.sealBarTemperatureSetting := 300;
	enableHeater := TRUE;
	
	bagDeliveryMode := DEVICE_MODES.Auto;
	bagDelivery.Reset();
	bagDelivery.enable := TRUE;
	IF iPowerOffButtonONS.OSR THEN
		bagDelivery.AutoFeedToEye();
	END_IF
	
	
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
	passthrough.Reset();
	pressureBarEndStopMotor.Reset();
	passthroughMode := DEVICE_MODES.Auto;
	passthrough.enable := TRUE;
	IF passthrough.homeRequired THEN
		homeJawPB := TRUE;
	ELSE
		pressureBar.ExtendCylinderLowPressure();
	END_IF
	oVacOn := FALSE;
	rearLoadPlateRetract.Reset();
	forwardLoadPlateRetract.Reset();
	loadShelfExtend.Reset();
	LPA.Reset();
	LPA.ManualOff();
	HPA.Reset();
	exitConveyorRun.Reset();
	oSealBarExtend := FALSE;
	oSealBarRetract := TRUE;
	sealTimer.IN := FALSE;
	//HMIData.airFilterClean.SetCount(27336);
	//HMIData.driveRollerClean.SetCount(12041);
	//HMIData.printHeadClean.SetCount(3224);
	//HMIData.pressureBarGuideShaftGuides.SetCount(127888);
	
	//HMIData.bagLength := 23.5;
	//HMIData.bagWidth := 17.5;
	//HMIData.bagReverseSpeed := 3;
// 	HMIData.printLength := 8;
// 	HMIData.printOffset := 1;
// 	HMIData.printSpeed := 6;
// 	HMIData.bagForwardSpeed := 50;
	state := HEAD_STATES.Idle;
	reset();
	setPassthroughPB := FALSE;
	//homeJawPB := FALSE;
	HMIData.jobLoadRequired.active := TRUE;
	HMIData.makeReady := FALSE;
	
	hmiLight.TurnOff();
	
END_IF
IF enableONS.Q OR resetONS.Q THEN
    state := HEAD_STATES.Idle;
	sealAndSeparateSubState := SEAL_SEPARATE_STATES.Idle;
	releaseAndFeedSubState := RELEASE_FEED_STATES.Idle;
	openBagSubState := BAG_OPEN_ASSIST_STATES.Idle;
	motorizedSealFlatteners.Reset();
	pressureBar.Reset();
	bagDelivery.Reset();
	zebraPrinter.Reset();
	//pressureBar.ExtendCylinderLowPressure();
	bagDropTimer.IN := FALSE;
	_reset := FALSE;
//	bagFailedToOpen := FALSE;
END_IF

{warning 'TODO: Put this inside the passtrough FB'}
IF passthrough.exhaustPressureBarRequest THEN
    pressureBar.ExhaustCylinder();
	IF NOT oPBar1Extend AND NOT oPBar1Retract THEN
		passthrough.AckRequest();
	END_IF
ELSIF passthrough.extendPressureBarRequest THEN
    pressureBar.ExtendCylinderLowPressure();
	IF oPBar1Extend AND oPBar1Retract THEN
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

// Disable the printer on dry cycle because we dont't want to print on the platen roller               
IF Globals.enableDryCycle THEN
    zebraPrinter.enable := FALSE;
END_IF
                


// Clear batch count on batch enable
enableBatchONS(CLK := enableBatch);
IF enableBatchONS.Q THEN
    batchCount := 0;
END_IF

IF NOT enable OR NOT readyToRun OR faultONS.OSR THEN
    state := HEAD_STATES.Fault;
	enableBatch := FALSE;
	pressureBarEndStopMotor.Stop();
	cycleTimer.IN := FALSE;
END_IF

cycleTimer();
IF state <> HEAD_STATES.Idle AND HMIData.initiateCycle THEN
	HMIData.initiateCycle := FALSE;
END_IF
CASE state OF
    HEAD_STATES.Idle :                                // Start cycle if enabled
													
													
                                                    IF startCycle 
													OR (enableBatch AND (batchCount < batchSetting))
													OR (HMIData.factoryTestMode AND (HMIData.bagsMade.count < 1000)) AND factoryTestModeKeepCycling AND NOT LPA.Q
													OR (iLeftPalmButton AND iRightPalmButton) 
													OR (HMIData.initiateCycle AND readyToRun) 
													AND NOT HMIData.faultActive 
													AND NOT HMIData.stopMachine 
													AND NOT setPassthroughPB THEN
                                                        state := HEAD_STATES.SealAndSeparateBag;
                                                        startCycle := FALSE;
														
														cycleTimer.IN := TRUE;
                                                    END_IF
                                                    IF (HMIData.passthroughSetting <> passthroughSettingLast) AND NOT pressureBarEndStopMotor.Faulted AND NOT pressureBarEndStopMotor.HomeRequired THEN
															setPassthroughPB := TRUE;
															passthroughSetting := HMIData.passthroughSetting;
															passthroughSettingLast := HMIData.passthroughSetting;
													END_IF
													
													IF NOT pressureBarEndStopMotor.HomeRequired OR pressureBarEndStopMotor.Faulted
														AND NOT motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.homeRequiredIndication OR motorizedSealFlatteners.sealFlattenersHorizontalAxisMotor.Faulted
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
                                                    sealAndSeparateSubState := SEAL_SEPARATE_STATES.MoveJawIn;
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
                                                        state := HEAD_STATES.Idle;
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
														 HMIData.bagsMade.Increment();
                                                        state := HEAD_STATES.Idle;
														cycleTime := (TIME_TO_REAL(cycleTimer.ET) / 1000); 
														cycleTimer.IN := FALSE;
														//bagFailedToOpen := FALSE;
														IF HMIData.factoryTestMode AND NOT HMIData.stopMachine THEN
															IF (HMIData.bagsMade.count >= 1000) THEN
																factoryTestModeKeepCycling := FALSE;
																HMIData.factoryTestMode := FALSE;
															ELSE
																factoryTestModeKeepCycling := TRUE;
															END_IF
														END_IF
                                                    END_IF
    HEAD_STATES.StartHoming :            // 
                                            passthrough.HomeEndStop();
                                            state := HEAD_STATES.Homing;                                        
    
    HEAD_STATES.Homing :                // 
                                            IF passthrough.state = PASSTHROUGH_SERVO_STATES.HomeComplete THEN
                                                state := HEAD_STATES.HomingComplete;       
                                            END_IF
                                            
    HEAD_STATES.HomingComplete :        // 
                                            homeJawPB := FALSE;
                                            state := HEAD_STATES.Idle;
											//HMIData.passthroughSetting := 6.0;
											setPassthroughPB := TRUE;
    
    HEAD_STATES.MovePassthrough :        // 
                                            pressureBar.AutoMovingPassthrough();
                                            passthrough.MovePassthrough(passthroughSetting);
                                            state := HEAD_STATES.MovingPassthrough;
    
    HEAD_STATES.MovingPassthrough :    IF passthrough.state = PASSTHROUGH_SERVO_STATES.PassthroughMovedIn OR passthrough.state = PASSTHROUGH_SERVO_STATES.PassthroughMovedOut THEN
                                                state := HEAD_STATES.MovedPassthrough;     
                                            END_IF
                                            
    HEAD_STATES.MovedPassthrough :        // 
                                            pressureBar.AutoDoneMovingPassthrough();
                                            state := HEAD_STATES.Idle;
											setPassthroughPB := FALSE;    
                                                    
    HEAD_STATES.Fault :                     hmiLight.TurnOff();   
											
											oVacOn := FALSE;
											LPA.ManualOff();
											setPassthroughPB := FALSE;
											homeJawPB := FALSE;
											startCycle := FALSE;
											HMIData.initiateCycle := FALSE;
											factoryTestModeKeepCycling := FALSE;   
                                                    
END_CASE

CASE sealAndSeparateSubState OF
    SEAL_SEPARATE_STATES.Idle : 
        
    SEAL_SEPARATE_STATES.MoveJawIn :                // Perform actions as enabled - close jaw and move flatteners out. If jaw is disabled then go right to reverse bag
                                                    IF motorizedSealFlatteners.enable THEN
                                                        motorizedSealFlatteners.AutoMoveOut();
                                                    END_IF
                                                    
                                                    IF pressureBar.enable THEN
                                                        pressureBar.AutoCloseJaw();
                                                        sealAndSeparateSubState := SEAL_SEPARATE_STATES.MovingJawIn;
                                                    ELSE 
                                                        sealAndSeparateSubState := SEAL_SEPARATE_STATES.ReverseBag;
                                                    END_IF
                                                    
                                                    
                                                    
                                                    
    SEAL_SEPARATE_STATES.MovingJawIn :                // If Jaw is in and flatteners out then move on
                                                    IF (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersOut OR NOT motorizedSealFlatteners.enable) 
                                                        AND (pressureBar.state = PRESSURE_BAR_STATES.JawClosed OR NOT pressureBar.enable)
                                                        THEN
                                                            sealAndSeparateSubState := SEAL_SEPARATE_STATES.MovedJawIn;    
                                                    END_IF
                                                                
    SEAL_SEPARATE_STATES.MovedJawIn :                // Will add sealing logic here
                                                    sealAndSeparateSubState := SEAL_SEPARATE_STATES.ReverseBag;
                                                    
    SEAL_SEPARATE_STATES.ReverseBag :                // Reverse bag if bag delivery enabled, otherwise open jaw
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
                                                        AND (pressureBar.state = PRESSURE_BAR_STATES.JawClosed OR NOT pressureBar.enable)
                                                        AND ((bagDelivery.state = BAG_DELIVERY_STATES.ReverseDone) OR Globals.enableDryCycle)
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
															
															IF enableLoadPlate THEN
																rearLoadPlateRetract.Trigger();
																exitConveyorRun.Trigger();
															END_IF
															
															IF enableLabelSideUp THEN
																forwardLoadPlateRetract.Trigger();
																loadShelfExtend.Trigger();
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
    
													(*{warning 'TODO: This is a hack to use HPA as LPA'}
														HPA.DwellSetting := 1500;		// Get rid on this - ha
														HPA.Trigger();	*)	
													IF (bagdelivery.state = BAG_DELIVERY_STATES.Ready OR NOT bagdelivery.enable)
                                                        AND (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.MovedFlattenersToBagFeed OR NOT motorizedSealFlatteners.enable) 
                                                        AND (pressureBar.state = PRESSURE_BAR_STATES.JawOpened OR NOT pressureBar.enable)
                                                        THEN
															LPA.ManualOff();
                                                            releaseAndFeedSubState := RELEASE_FEED_STATES.MovedJawOutAndFedBag;
                                                    END_IF
                                                    
    RELEASE_FEED_STATES.MovedJawOutAndFedBag :        releaseAndFeedSubState := RELEASE_FEED_STATES.Done;
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
                                                                   
                                                    
                                                    
    BAG_OPEN_ASSIST_STATES.MoveJawOut :                // Open the jaw and move seal flatteners in and to bag holding
                                                    pressureBar.AutoOpenJaw();
													motorizedSealFlatteners.AutoMoveIn();
                                                    openBagSubState := BAG_OPEN_ASSIST_STATES.MovingJawOutAndGrab;
                                                    
                                                    
    BAG_OPEN_ASSIST_STATES.MovingJawOutAndGrab :    // Once everything that is enabled is homed finish cycle 
													bagOpenFingerDelay.IN := TRUE;
													IF bagOpenFingerDelay.Q THEN
														bagOpenFingers.Grab();
														bagOpenFingerDelay.IN := FALSE;
														(*{warning 'TODO: This is a hack to use HPA as LPA'}
														HPA.DwellSetting := 200;		// Get rid on this - ha
														HPA.Trigger();*)
														openBagSubState := BAG_OPEN_ASSIST_STATES.CheckForSuccessfulBagGrab;
													END_IF
													  

	BAG_OPEN_ASSIST_STATES.CheckForSuccessfulBagGrab : 	//
														IF bagOpenRetryCount < bagOpenRetrySetting THEN
															bagOpenCheckDelay.IN := TRUE;
															IF bagOpenCheckDelay.Q THEN
																IF bagOpenFingers.CheckIfBagGrabbed() THEN // This method checks to see if the bag is grabbed and returns true if so.
																	openBagSubState := BAG_OPEN_ASSIST_STATES.BagOpened;
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
														ELSE 
															//IF (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.Idle OR NOT motorizedSealFlatteners.enable) THEN
																motorizedSealFlatteners.AutoMoveToBagHolding();
																bagFailedToOpen.Trigger();
																
																openBagSubState := BAG_OPEN_ASSIST_STATES.MovingJawOutAfterGrab;
																bagOpenRetryCount := 0; 
																HMIData.bagsRejectedTotal.Increment();
																Globals.rejectedBagCount := Globals.rejectedBagCount + 1;
															//END_IF
															
														END_IF
	
	BAG_OPEN_ASSIST_STATES.BagOpened :					//
														
                                                    	motorizedSealFlatteners.AutoMoveToBagHolding();
														bagOpenRetryCount := 0;
														
														HMIData.airFilterClean.Increment();
														HMIData.baggerCycles.Increment();
														openBagSubState := BAG_OPEN_ASSIST_STATES.MovingJawOutAfterGrab; 
														
                                      
    BAG_OPEN_ASSIST_STATES.MovingJawOutAfterGrab :		// 
														IF (pressureBar.state = PRESSURE_BAR_STATES.JawOpened OR NOT pressureBar.enable) 
															AND (motorizedSealFlatteners.state = SEAL_FLATTENER_STATES.Idle OR NOT motorizedSealFlatteners.enable)
															THEN
																openBagSubState := BAG_OPEN_ASSIST_STATES.MovedJawOut;        
														END_IF	 
														
	
	BAG_OPEN_ASSIST_STATES.MovedJawOut :            // 
														oVacOn := FALSE; 		// Hard coded for now, this is vacuum
														IF LPA.DwellSetting <> 0 THEN
															LPA.Trigger();
														END_IF
														
														openBagSubState := BAG_OPEN_ASSIST_STATES.Done;

                                                             
                                                
	BAG_OPEN_ASSIST_STATES.FeedNewBag :   			//
													
													
                                                
    BAG_OPEN_ASSIST_STATES.Done :                    // 
                                                            
    BAG_OPEN_ASSIST_STATES.Fault :                    //
													

END_CASE