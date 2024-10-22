(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PROGRAM PLC_PRG_1
VAR
	firstScanDone: BOOL;
	firstAborted :BOOL:=TRUE;
	cycleStartONS : FB_ONS;
	//powerUpFrontJawMotor : MC_Power;
	powerUpRearJawMotor : MC_Power;
	powerUpBothJawMotors : MC_Power;
	powerUpLoadPlateMotor : MC_Power;
	powerUpBagDeliveryMotor : MC_Power;
	powerUpIBDMotor : MC_Power;
	UN00_SXMachine : FB_UN00_SharpMachine(name := 'UN00 - Sharp SX');
	EM01_SXBaggerHead : EM01_BaggerHead(name := 'EM01 - SX Bagger Head');
	EM02_SXDischarge : EM02_Discharge(name := 'EM02 - SX Discharge');
	baggerCM : EM01_BaggerCM;
	dischargeCM : EM02_DischargeCM;
	bannerManager : FB_BannerManager;
	hmiFaultMessage : FB_FaultMessageHandler;
	palmButton : FB_BannerPalmButton;
	safePowerOffFault : FB_Fault(name := 'Safety Circuit Broken During Cycle');
	eStopPressedFault : FB_Fault(name := 'E-Stop Pressed');
	amazonBPM : FB_AmazonThroughput();
	printerLabel : FB_PrinterSerial();
	autoModeTimer : Standard.TON;
	autoModeKeepCycling : BOOL;
	autoModeInitiateCycleONS : FB_ONS;
	cycleComplete : FB_ONS;
	hIecTask : RTS_IEC_HANDLE;//Declaration of the variable hIecTask
	teachPhotoeyeTimer : Standard.TOF() := (PT := T#3S);
	//variables for the state timer
	stateTimer:TON;
	laststate: INT;
	count_index :INT :=0;
	clr:BOOL:=FALSE;
	speedTracking : ARRAY[0..20] OF ARRAY[0..20] OF TIME;
	speedTracking_mt : ARRAY[0..20] OF ARRAY[0..20] OF TIME:=[21([21(T#0S)])]; 
	state_index : INT:=0;
	hold: BOOL;
	loadPlateInterlocks: DINT := 0;
	resetHold: Ton;
	flipFlop: TON;
	batchCounter : CTU;
	cycleStartDebounce : TON := (PT := T#75MS);
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Program: PLC_PRG
//	Description: Base program for the 1179/1181 SX. 
//				 
//	Created by: Ben Hess
//	Created Date: 

IO_Map();
// Initialze global objects on first scan
IF NOT firstScanDone THEN
	GlobalObjects.CollectionOfInitialzable.InitializeAll();
	GlobalObjects.CollectionOfLoggable.RegisterAll(internalLogger := GlobalData.SystemLog);
	GlobalObjects.CollectionOfFaults.FaultUpdateForHMI();
	hIecTask := IecTaskGetCurrent(0);
	IecTaskDisableWatchdog(hIecTask); // Watchdog disabled
	firstScanDone := TRUE;
END_IF
IF firstAborted AND UN00_SXMachine.currentState = PACK_ML.State.Aborted THEN
	firstAborted := FALSE;
END_IF
IF flipFlop.Q THEN
	HMIData.counterChange := NOT HMIData.counterChange; 
END_IF
flipFlop(IN := not flipFlop.Q,PT := T#500MS);
// Use fault collection for faultActive indication
HMIData.faultActive := GlobalObjects.CollectionOfActiveFaults.faultActive;

// Cycle start conditions
// Auto mode dwell timer
autoModeTimer(PT := TO_TIME(HMIData.autoModeDwell * 1000), IN := autoModeKeepCycling AND UN00_SXMachine.currentState = PACK_ML.State.Execute AND NOT HMIData.inCycle);
// Start from Cycle Start input
cycleStartDebounce(IN := iCycleStart);
cycleStartONS(clk := cycleStartDebounce.Q);
// Batch Counter
batchCounter(CU := cycleComplete.OSR, RESET := (NOT HMIData.batchEnable) OR HMIData.resetBatchCounter, PV := TO_WORD(HMIData.batchSetting), Q => HMIData.batchCounterDone, CV => HMIData.batchCount);
IF HMIData.resetBatchCounter THEN 
	HMIData.resetBatchCounter := FALSE;
END_IF
// All start conditions
IF (HMIData.initiateCycle OR cycleStartONS.OSR OR autoModeTimer.Q) AND NOT HMIData.batchCounterDone THEN
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
baggerCM(inhibitMotion:= firstAborted);
dischargeCM(loadPlateInterlocks:= loadPlateInterlocks);

// Set bagger head control modules
EM01_SXBaggerHead(
	bagOpenFingers:= baggerCM.BOF, 
	sealFlatteners:= baggerCM.SealFlatteners, 
	sealer:= baggerCM.sealWire, 
	pressureBar:= baggerCM.dualMotorPassthrough, 
	printer:= baggerCM.labelPrinter, 
	bagDelivery:= baggercm.bagDelivery, 
	vacuumBagOpen:= baggerCM.VacuumCups, 
	IBD:= baggerCM.IBD, 
	loadPlate:= dischargeCM.loadPlate, 
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
IF HMIData.inCycle AND NOT iSafePowerOK THEN
	safePowerOffFault.Trigger();
END_IF
IF NOT iEstopNormal THEN
	eStopPressedFault.Trigger();
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

// change jaw close position from HMI
AxisData.jawCloseMotionProfile.position := HMIData.jawClosePositionSetting;

//code to add timer to track duration in states
stateTimer(PT:=T#10000S);
stateTimer.IN := UN00_SXMachine.baggerManager.BaggerAutoMode.baggerCycleActive;
IF clr THEN
	speedTracking:=speedTracking_mt;
	clr:=FALSE;
END_IF
IF UN00_SXMachine.baggerManager.BaggerAutoMode.baggerCycleActive AND NOT hold THEN
		count_index := count_index +1;
		hold:=TRUE;
ELSIF hold AND NOT UN00_SXMachine.baggerManager.BaggerAutoMode.baggerCycleActive THEN
	hold := FALSE;	
END_IF
IF stateTimer.ET>T#0MS THEN
	speedTracking[state_index][count_index] := stateTimer.ET;
END_IF
IF count_index >=20 THEN
	count_index :=0;
END_IF
resetHold(IN:=HMIData.ackAllFaults,PT:=T#5000MS);
IF HMIData.ackAllFaults THEN
	IF UN00_SXMachine.currentState = PACK_ML.State.Resetting OR resetHold.Q THEN
		HMIData.ackAllFaults:= FALSE;
	END_IF
END_IF

//End modded code
// Send the list of active fault strings to HMI for viewing
HMIData.activeFaults := GlobalObjects.CollectionOfActiveFaults.ObjNames;
hmiFaultMessage(faultActive:= GlobalObjects.CollectionOfActiveFaults.faultActive,faultList:= GlobalObjects.CollectionOfActiveFaults.ObjNames);
HMIData.faultMessage:=hmiFaultMessage.faultMessagestr;
HMIData.inCycle := UN00_SXMachine.baggerManager.BaggerAutoMode.baggerCycleActive;
GlobalObjects.CollectionOfComponents.UpdateInfo();
// PackML state to string for HMI
HMIData.currentPackMLState := UN00_SXMachine.baggerManager.BaggerAutoMode.currentBaggerState;

oFansEnable := NOT HMIData.standbyActive;

// Banner manager takes care of the Multistate lamp used as a banner on the proface 
bannerManager(
	baggerNotReady:= NOT UN00_SXMachine.currentState = PACK_ML.State.Execute, 
	baggerReady:= GlobalObjects.CollectionOfComponents.CheckIfAllReady() AND UN00_SXMachine.currentState = PACK_ML.State.Execute AND NOT HMIData.inCycle AND NOT HMIData.batchCounterDone, 
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
	filmFeedMotorFault:=  baggerCM.bagDeliveryFrontMotor.error OR baggerCM.bagDelivery.reverseFault.Active,
	jawMotionFault:= baggerCM.jawFrontMotor.error OR baggerCM.dualMotorPassthrough.frontMotorFault.Active OR baggerCM.dualMotorPassthrough.frontMotorCommFault.Active,
	//jawMotionFault:= baggerCM.dualMotorPassthrough.bothMotorsFault.Active, 
	waitingOnPrinter:= UN00_SXMachine.baggerManager.BaggerAutoMode.releaseAndFeedSubState = RELEASE_FEED_STATES.WaitForPrinter,
	waitingOnFiller:= , 
	batchCounterDone:= HMIData.batchCounterDone, 
	jawNotHomed:= NOT baggerCM.dualMotorPassthrough.IsHomed AND NOT HMIData.inCycle, 
	cycleBaggerTForFiller:= , 
	machineNotTested:=  HMIData.bagsMade < 1000, 
	//loadPlateMotorNotHomed:= NOT baggerCM.loadPlate.IsHomed AND baggerCM.loadPlate.OptionActive, 
	//loadPlateMotorFaulted:= baggerCM.loadPlate.motorFault.Active, 
	//loadPlateMotorCommF:= baggerCM.loadPlate.motorCommFault.Active, 
	safePowerFault:= safePowerOffFault.Active, 
	safePowerWarning:= NOT iSafePowerOK AND NOT HMIData.inCycle, 
	//IBDMotorNotHomed:= NOT baggerCM.IBD.IsHomed AND baggerCM.IBD.OptionActive AND NOT HMIData.inCycle, 
	//IBDMotorFaulted:= baggerCM.IBD.IBDMotorFault.Active, 
	//IBDMotorCommF:= baggerCM.IBD.IBDMotorCommFault.Active, 
	printerRibbonFault := baggerCM.labelPrinter.ribbonFault.Active,
	printerServiceRequired := baggerCM.labelPrinter.serviceRequired.Active,
	jawFailedToOpen:= baggerCM.dualMotorPassthrough.failedToOpen.Active, 
	IBDFailedToClose:= baggerCM.dualMotorPassthrough.failedToClose.Active, 
	//IBDFailedToOpen:= baggerCM.IBD.failedToOpen.Active, 
	messageDisplayIndication=> HMIData.bannerMessageIndication);

// Ready indications for bagger control modules
HMIData.printerReady := baggerCM.labelPrinter.Ready;
HMIData.bagDeliveryReady := baggerCM.bagDelivery.Ready;
//HMIData.loadPlateReady := baggerCM.loadPlate.Ready;
HMIData.jawReady := baggerCM.dualMotorPassthrough.Ready;
HMIData.bcvReady := baggerCM.barcodeVerifier.Ready;
HMIData.IBDReady := baggerCM.IBD.Ready;

// Motor data to HMI for troubleshooting
HMIData.frontJawMotorData.ActPos := baggerCM.jawFrontMotor.ActPos;
HMIData.frontJawMotorData.CommandedPos := baggerCM.jawFrontMotor.TargetPosDist;
HMIData.frontJawMotorData.CurrentAlarmCode := baggerCM.jawFrontMotor.alarmCode;


//HMIData.bagDeliveryMotorData.alarmCode := baggerCM.bagDeliveryFrontMotor.alarmCode;;



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

//HMIData.IBDService.extendedFeedback := baggerCM.IBD._isFullyOpen;
//HMIData.IBDService.retractedFeedback := NOT baggerCM.IBD._isFullyOpen;

HMIData.printHeadService.extendedFeedback := oLowerPrinthead;
HMIData.printHeadService.retractedFeedback := NOT oLowerPrinthead;

// Amazon Bags per minute throughput calculator
amazonBPM(
	inCycle:= HMIData.inCycle, 
	runtimeTimeout:= , 
	reset:= HMIData.BPMReset, 
	BPM=> HMIData.BPMBagsPerMinute, 
	BPMCycles=> HMIData.BPMBagsMade, 
	BPMSeconds=> , 
	BPMIndication=> HMIData.BPMActiveTime);
