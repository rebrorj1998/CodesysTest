(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PROGRAM PLC_PRG
VAR
	
	firstScanDone: BOOL;
	cycleStartONS : FB_ONS;
	powerUpFrontJawMotor : MC_Power;
	powerUpRearJawMotor : MC_Power;
	powerUpBothJawMotors : MC_Power;
	powerUpLoadPlateMotor : MC_Power;
	powerUpBagDeliveryMotor : MC_Power;
	powerUpIBDMotor : MC_Power;
	UN00_SXMachine : FB_UN00_SharpMachine(name := 'UN00 - Sharp SX');
	EM01_SXBaggerHead : EM01_BaggerHead(name := 'EM01 - SX Bagger Head');
	EM02_SXDischarge : EM02_Discharge(name := 'EM02 - SX Discharge');
	baggerCM : EM01_Bagger_Control_Modules;
	bannerManager : FB_BannerManager;
	palmButton : FB_BannerPalmButton;
	topCoverLiftedFault : FB_Fault(name := 'Top Cover Lifeted During Cycle');
	amazonBPM : FB_AmazonThroughput();
	printerLabel : FB_PrinterSerial();
	autoModeTimer : Standard.TON;
	autoModeKeepCycling : BOOL;
	autoModeInitiateCycleONS : FB_ONS;
	cycleComplete : FB_ONS;
	hIecTask : RTS_IEC_HANDLE;//Declaration of the variable hIecTask
	teachPhotoeyeTimer : Standard.TOF() := (PT := T#3S);
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Program: PLC_PRG
//	Description: Base program for the 1179/1181 SX. 
//				 
//	Created by: Ben Hess
//	Created Date: 




// Initialze global objects on first scan
IF NOT firstScanDone THEN
	GlobalObjects.CollectionOfInitialzable.InitializeAll();
	GlobalObjects.CollectionOfLoggable.RegisterAll(internalLogger := Globals.SystemLog);
	GlobalObjects.CollectionOfFaults.FaultUpdateForHMI();
	hIecTask := IecTaskGetCurrent(0);
	IecTaskDisableWatchdog(hIecTask); // Watchdog disabled
	firstScanDone := TRUE;
END_IF

// Teach bag photoeye
teachPhotoeyeTimer(IN := HMIData.teachBagPhotoeye, Q => oTeachPhotoeye);
HMIData.teachingBagPhoteye := oTeachPhotoeye;


// Use fault collection for faultActive indication
HMIData.faultActive := GlobalObjects.CollectionOfActiveFaults.faultActive;


// Cycle start conditions
// Auto mode dwell timer
autoModeTimer(PT := TO_TIME(HMIData.autoModeDwell * 1000), IN := autoModeKeepCycling AND UN00_SXMachine.currentState = PACK_ML.State.Execute AND NOT HMIData.inCycle);
// Start from Cycle Start input
cycleStartONS(clk := iCycleStart);
// All start conditions
IF HMIData.initiateCycle OR cycleStartONS.OSR OR autoModeTimer.Q THEN
	IF UN00_SXMachine.currentState = PACK_ML.State.Execute AND NOT HMIData.inCycle THEN
		EM01_SXBaggerHead.StartCycle();
		IF HMIData.autoModeEnable THEN
			autoModeKeepCycling := TRUE;
		END_IF
	END_IF
	HMIData.initiateCycle := FALSE;
END_IF
// Unlatch flag for auto mode when faulted or stopped
IF UN00_SXMachine.currentState <> PACK_ML.State.Execute OR HMIData.ackAllFaults OR NOT HMIData.autoModeEnable THEN
	autoModeKeepCycling := FALSE;
END_IF

// Only faults execute automatically to handle acking and clearing without being run in each FB that contains them
IF firstScanDone THEN
	GlobalObjects.CollectionOfExecutable.ExecuteAll();
END_IF


// Power up all motors
powerUpFrontJawMotor(Enable := TRUE, Axis := baggerCM.jawFrontMotor);
powerUpFrontJawMotor.DriveStart := TRUE;
powerUpFrontJawMotor.RegulatorOn := TRUE;

powerUpRearJawMotor(Enable := TRUE, Axis := baggerCM.jawRearMotor);
powerUpRearJawMotor.DriveStart := TRUE;
powerUpRearJawMotor.RegulatorOn := TRUE;

powerUpBothJawMotors(Enable := TRUE, Axis := baggerCM.jawBothMotors);
powerUpBothJawMotors.DriveStart := TRUE;
powerUpBothJawMotors.RegulatorOn := TRUE;

powerUpLoadPlateMotor(Enable := HMIData.loadPlateInstalled, Axis := baggerCM.loadPlateMotor);
powerUpLoadPlateMotor.DriveStart := HMIData.loadPlateInstalled;
powerUpLoadPlateMotor.RegulatorOn := HMIData.loadPlateInstalled;

powerUpBagDeliveryMotor(Enable := TRUE, Axis := baggerCM.bagDeliveryFrontMotor);
powerUpBagDeliveryMotor.DriveStart := TRUE;
powerUpBagDeliveryMotor.RegulatorOn := TRUE;

powerUpIBDMotor(Enable := HMIData.IBDInstalled, Axis := baggerCM.IBDMotor);
powerUpIBDMotor.DriveStart := HMIData.IBDInstalled;
powerUpIBDMotor.RegulatorOn := HMIData.IBDInstalled;

// Disable Modbus device tree objects if option not installed
// IF NOT HMIData.loadPlateInstalled THEN
// 	Load_Plate_Motor.Enable := FALSE;
// ELSE
// 	Load_Plate_Motor.Enable := TRUE;
// END_IF
// 
// IF NOT HMIData.IBDInstalled THEN
// 	IBD_Motor.Enable := FALSE;
// ELSE
// 	IBD_Motor.Enable := TRUE;
// END_IF

// Barcode Verifier manual trigger
IF HMIData.barcodeVerifierTrigger THEN
	baggerCM.barcodeVerifier.TriggerImmediate();
	HMIData.barcodeVerifierTrigger := FALSE;
END_IF

// Printer sample label sending
IF HMIData.sendSampleLabels AND NOT printerLabel.xExecute THEN
	printerLabel.xExecute := TRUE;
	printerLabel.sendSampleLabel := TRUE;
	printerLabel.sendClearLabel := FALSE;
	HMIData.sendSampleLabels := FALSE;
ELSIF HMIData.clearAllLabels AND NOT printerLabel.xExecute THEN
	printerLabel.xExecute := TRUE;
	printerLabel.sendSampleLabel := FALSE;
	printerLabel.sendClearLabel := TRUE;
	HMIData.clearAllLabels := FALSE;
END_IF

IF printerLabel.xDone THEN
	printerLabel.xExecute := FALSE;
END_IF
printerLabel();

// Run collection of bagger control modules
baggerCM();

// Set bagger head control modules
EM01_SXBaggerHead(
	bagOpenFingers:= baggerCM.dummyBOF, 
	sealFlatteners:= baggerCM.dummySealFlatteners, 
	sealer:= baggerCM.sealWire, 
	pressureBar:= baggerCM.dualMotorPassthrough, 
	printer:= baggerCM.labelPrinter, 
	bagDelivery:= baggercm.bagDelivery, 
	vacuumBagOpen:= baggerCM.dummyVacuumCups, 
	IBD:= baggerCM.IBD, 
	loadPlate:= baggerCM.loadPlate, 
	barcodeVerifier:= baggerCM.barcodeVerifier, 
	bagOpenAssistEnabled:= FALSE, 
	bagOpenSensorEnabled:= FALSE, 
	cancelPrint := HMIData.printerCancelRequest,
	separateBeforeSealEnabled:= HMIData.separateBeforeSeal, 
	bagOpenRetrySetting:= , 
	newJobLoaded:= , 
	vacuumDwell:= , 
	bagOpenRetryCount=> , 
	failedToOpenBag=> );
	

EM02_SXDischarge();

// Machine unit
UN00_SXMachine(faultActive:= HMIData.faultActive, resetMachine := HMIData.ackAllFaults, homeMachine := HMIData.homeMachine, currentState=> , baggerHead:= EM01_SXBaggerHead, discharge:= EM02_SXDischarge);

// Trigger fault if top cover lifted during cycle
IF HMIData.inCycle AND NOT iTopCoverClosed THEN
	topCoverLiftedFault.Trigger();
END_IF


// Banner palm button has 4 states - off, solid green, 50/50 green/white rotating, and flashing red
palmButton(
	baggerReady:= UN00_SXMachine.currentState = PACK_ML.State.Execute, 
	baggerFaulted:= HMIData.faultActive, 
	baggerInCycle:= HMIData.inCycle, 
	palmState0Output=> oPalmButton0, 
	palmState1Output=> oPalmButton1);
	
//
// HMI Mapping
//

// Send the list of active fault strings to HMI for viewing
HMIData.activeFaults := GlobalObjects.CollectionOfActiveFaults.ObjNames;

HMIData.inCycle := UN00_SXMachine.baggerManager.BaggerAutoMode.baggerCycleActive;
// PackML state to string for HMI
HMIData.currentPackMLState := UN00_SXMachine.baggerManager.BaggerAutoMode.currentBaggerState;


// Banner manager takes care of the Multistate lamp used as a banner on the proface 
bannerManager(
	baggerNotReady:= NOT UN00_SXMachine.currentState = PACK_ML.State.Execute, 
	baggerReady:= UN00_SXMachine.currentState = PACK_ML.State.Execute AND NOT HMIData.inCycle, 
	baggerInCycle:= HMIData.inCycle, 
	noBagCoveringEye:= baggerCM.bagDelivery.noBagOverEye.Active, 
	bagFailedToSeperate:= baggerCM.bagDelivery.bagFailedToSeparate.Active, 
	pbarObstruction:= baggerCM.dualMotorPassthrough.pressureBarObstructed.Active, 
	lightCurtainViolation:= , 
	printHeadFTR:= baggerCM.labelPrinter.printHeadFailToRaise.Active, 
	printHeadFTL:= baggerCM.labelPrinter.printHeadFailToLower.Active, 
	barcodeFault:= EM01_SXBaggerHead.barcodeVerificationFailed.Active, 
	tooManyPartsCounted:= , 
	jawFailedToClose:= baggerCM.dualMotorPassthrough.failedToClose.Active, 
	jawFailedToHome:= baggerCM.dualMotorPassthrough.failedToHome.Active, 
	filmFeedMotionFault:= , 
	jawMotionFault:= baggerCM.dualMotorPassthrough.bothMotorsFault.Active, 
	waitingOnPrinter:= UN00_SXMachine.baggerManager.BaggerAutoMode.releaseAndFeedSubState = RELEASE_FEED_STATES.WaitForPrinter,
	waitingOnFiller:= , 
	batchCounterDone:= , 
	jawNotHomed:= NOT baggerCM.dualMotorPassthrough.IsHomed AND NOT HMIData.inCycle, 
	cycleBaggerTForFiller:= , 
	machineNotTested:=  HMIData.bagsMade < 1000, 
	loadPlateMotorNotHomed:= NOT baggerCM.loadPlate.IsHomed AND baggerCM.loadPlate.OptionActive, 
	loadPlateMotorFaulted:= baggerCM.loadPlate.motorFault.Active, 
	loadPlateMotorCommF:= baggerCM.loadPlate.motorCommFault.Active, 
	topCoverLiftedFault:= topCoverLiftedFault.Active, 
	topCoverLiftedWarning:= NOT iTopCoverClosed AND NOT HMIData.inCycle, 
	IBDMotorNotHomed:= NOT baggerCM.IBD.IsHomed AND baggerCM.IBD.OptionActive AND NOT HMIData.inCycle, 
	IBDMotorFaulted:= baggerCM.IBD.IBDMotorFault.Active, 
	IBDMotorCommF:= baggerCM.IBD.IBDMotorCommFault.Active, 
	printerRibbonFault := baggerCM.labelPrinter.ribbonFault.Active,
	printerServiceRequired := baggerCM.labelPrinter.serviceRequired.Active,
	jawFailedToOpen:= baggerCM.dualMotorPassthrough.failedToOpen.Active, 
	IBDFailedToClose:= , 
	IBDFailedToOpen:= baggerCM.IBD.failedToOpen.Active, 
	messageDisplayIndication=> HMIData.bannerMessageIndication);

// Ready indications for bagger control modules
HMIData.printerReady := baggerCM.labelPrinter.Ready;
HMIData.bagDeliveryReady := baggerCM.bagDelivery.Ready;
HMIData.loadPlateReady := baggerCM.loadPlate.Ready;
HMIData.jawReady := baggerCM.dualMotorPassthrough.Ready;
HMIData.bcvReady := baggerCM.barcodeVerifier.Ready;
HMIData.IBDReady := baggerCM.IBD.Ready;

// Motor data to HMI for troubleshooting
HMIData.frontJawMotorData.ActPos := baggerCM.jawFrontMotor.ActPos;
HMIData.frontJawMotorData.CommandedPos := baggerCM.jawFrontMotor.TargetPosDist;
HMIData.frontJawMotorData.CurrentAlarmCode := baggerCM.jawFrontMotor.alarmCode;

HMIData.rearJawMotorData.ActPos := baggerCM.jawRearMotor.ActPos;
HMIData.rearJawMotorData.CommandedPos := baggerCM.jawRearMotor.TargetPosDist;
HMIData.rearJawMotorData.CurrentAlarmCode := baggerCM.jawRearMotor.alarmCode;

HMIData.IBDMotorData.ActPos := baggerCM.IBDMotor.ActPos;
HMIData.IBDMotorData.CommandedPos := baggerCM.IBDMotor.TargetPosDist;
HMIData.IBDMotorData.CurrentAlarmCode := baggerCM.IBDMotor.alarmCode;

HMIData.loadPlateMotorData.ActPos := baggerCM.loadPlateMotor.ActPos;
HMIData.loadPlateMotorData.CommandedPos := baggerCM.loadPlateMotor.TargetPosDist;
HMIData.loadPlateMotorData.CurrentAlarmCode := baggerCM.loadPlateMotor.alarmCode;

HMIData.bagDeliveryMotorData.alarmCode := baggerCM.bagDeliveryFrontMotor.alarmCode;
HMIData.bagDeliveryMotorData.statusCode := baggerCM.bagDeliveryFrontMotor.statusCode;



// Cycle time and bags made counters
HMIData.cycleTime := UN00_SXMachine.baggerManager.BaggerAutoMode.cycleTime;
HMIData.inCycle := UN00_SXMachine.baggerManager.BaggerAutoMode.cycleTimer.IN;
cycleComplete(CLK := UN00_SXMachine.baggerManager.BaggerAutoMode.cycleComplete);
IF cycleComplete.OSR THEN
	HMIData.bagsMade := HMIData.bagsMade + 1;
END_IF

// Printer and Barcode Verifier combination enable/disable
HMIData.printerAndVerifierEnableIndication := HMIData.printerInUse AND HMIData.barcodeVerifierInUse;
IF HMIData.printerAndVerifierEnablePB THEN
	IF HMIData.printerAndVerifierEnableIndication THEN
		HMIData.printerInUse := FALSE;
		HMIData.barcodeVerifierInUse := FALSE;
	ELSE
		HMIData.printerInstalled := TRUE;
		HMIData.barcodeVerifierInstalled := TRUE;
		HMIData.printerInUse := TRUE;
		HMIData.barcodeVerifierInUse := TRUE;
	END_IF
	HMIData.printerAndVerifierEnablePB := FALSE;
END_IF

// Position Indications for service commands
HMIData.jawService.extendedFeedback := baggerCM.dualMotorPassthrough.IsFullyOpen;
HMIData.jawService.retractedFeedback := baggerCM.dualMotorPassthrough.IsFullyClosed;

HMIData.IBDService.extendedFeedback := baggerCM.IBD._isFullyOpen;
HMIData.IBDService.retractedFeedback := NOT baggerCM.IBD._isFullyOpen;

HMIData.printHeadService.extendedFeedback := iPrintHeadLowered;
HMIData.printHeadService.retractedFeedback := NOT iPrintHeadLowered;

// Amazon Bags per minute throughput calculator
amazonBPM(
	inCycle:= HMIData.inCycle, 
	runtimeTimeout:= , 
	reset:= HMIData.BPMReset, 
	BPM=> HMIData.BPMBagsPerMinute, 
	BPMCycles=> HMIData.BPMBagsMade, 
	BPMSeconds=> , 
	BPMIndication=> HMIData.BPMActiveTime);
