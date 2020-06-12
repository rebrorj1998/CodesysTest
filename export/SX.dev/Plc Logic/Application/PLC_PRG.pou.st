(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PROGRAM PLC_PRG
VAR
	
	firstScanDone: BOOL;
	cycleStartONS : FB_ONS;
	powerUpFrontJawMotor : Sharp_Motion.MC_Power;
	powerUpRearJawMotor : Sharp_Motion.MC_Power;
	powerUpBothJawMotors : Sharp_Motion.MC_Power;
	powerUpLoadPlateMotor : Sharp_Motion.MC_Power;
	powerUpBagDeliveryMotor : Sharp_Motion.MC_Power;
	powerUpIBDMotor : Sharp_Motion.MC_Power;
	UN00_SXMachine : FB_UN00_SharpMachine(name := 'UN00 - Sharp SX');
	EM01_SXBaggerHead : EM01_BaggerHead(name := 'EM01 - SX Bagger Head');
	EM02_SXDischarge : EM02_Discharge(name := 'EM02 - SX Discharge');
	baggerCM : EM01_Bagger_Control_Modules_1;
	bannerManager : FB_BannerManager;
	palmButton : FB_BannerPalmButton;
	topCoverLiftedFault : FB_Fault(name := 'Top Cover Lifeted During Cycle');
	amazonBPM : FB_AmazonThroughput();
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF NOT firstScanDone THEN
	GlobalObjects.CollectionOfInitialzable.InitializeAll();
	GlobalObjects.CollectionOfLoggable.RegisterAll(internalLogger := Globals.SystemLog);
	GlobalObjects.CollectionOfFaults.FaultUpdateForHMI();
	firstScanDone := TRUE;
END_IF

IF HMIData.bagLength > 30 THEN
	HMIData.bagLength := 30;
END_IF

HMIData.faultActive := GlobalObjects.CollectionOfActiveFaults.faultActive;

cycleStartONS(clk := iCycleStart);
IF HMIData.initiateCycle OR cycleStartONS.OSR THEN
	IF UN00_SXMachine.currentState = PACK_ML.State.Execute THEN
		EM01_SXBaggerHead.StartCycle();
	END_IF
	HMIData.initiateCycle := FALSE;
END_IF

IF firstScanDone THEN
	GlobalObjects.CollectionOfExecutable.ExecuteAll();
END_IF

powerUpFrontJawMotor(Enable := TRUE, Axis := baggerCM.jawFrontMotor);
powerUpFrontJawMotor.DriveStart := TRUE;
powerUpFrontJawMotor.RegulatorOn := TRUE;

powerUpRearJawMotor(Enable := TRUE, Axis := baggerCM.jawRearMotor);
powerUpRearJawMotor.DriveStart := TRUE;
powerUpRearJawMotor.RegulatorOn := TRUE;

powerUpBothJawMotors(Enable := TRUE, Axis := baggerCM.jawBothMotors);
powerUpBothJawMotors.DriveStart := TRUE;
powerUpBothJawMotors.RegulatorOn := TRUE;

powerUpLoadPlateMotor(Enable := TRUE, Axis := baggerCM.loadPlateMotor);
powerUpLoadPlateMotor.DriveStart := TRUE;
powerUpLoadPlateMotor.RegulatorOn := TRUE;

powerUpBagDeliveryMotor(Enable := TRUE, Axis := baggerCM.bagDeliveryFrontMotor);
powerUpBagDeliveryMotor.DriveStart := TRUE;
powerUpBagDeliveryMotor.RegulatorOn := TRUE;

powerUpIBDMotor(Enable := TRUE, Axis := baggerCM.IBDMotor);
powerUpIBDMotor.DriveStart := TRUE;
powerUpIBDMotor.RegulatorOn := TRUE;

baggerCM();

HMIData.activeFaults := GlobalObjects.CollectionOfActiveFaults.ObjNames;



EM01_SXBaggerHead(
	bagOpenFingers:= baggerCM.dummyBOF, 
	sealFlatteners:= baggerCM.dummySealFlatteners, 
	sealer:= baggerCM.sealWire, 
	pressureBar:= baggerCM.dualMotorPassthrough, 
	printer:= baggerCM.labelPrinter, 
	bagDelivery:= POU.fastBagDelivery, 
	vacuumBagOpen:= baggerCM.dummyVacuumCups, 
	IBD:= baggerCM.IBD, 
	loadPlate:= baggerCM.loadPlate, 
	barcodeVerifier:= baggerCM.barcodeVerifier, 
	bagOpenAssistEnabled:= FALSE, 
	bagOpenSensorEnabled:= FALSE, 
	separateBeforeSealEnabled:= HMIData.separateBeforeSeal, 
	bagOpenRetrySetting:= , 
	newJobLoaded:= , 
	vacuumDwell:= , 
	baggerCycleActive=> HMIData.inCycle, 
	bagOpenRetryCount=> , 
	failedToOpenBag=> );
	
	
EM02_SXDischarge();

UN00_SXMachine(faultActive:= HMIData.faultActive, resetMachine := HMIData.ackAllFaults, homeMachine := HMIData.homeMachine, currentState=> , baggerHead:= EM01_SXBaggerHead, discharge:= EM02_SXDischarge);

HMIData.currentPackMLState := UN00_SXMachine.baggerManager.BaggerAutoMode.currentBaggerState;

IF HMIData.inCycle AND NOT iTopCoverClosed THEN
	topCoverLiftedFault.Trigger();
END_IF

IF NOT HMIData.loadPlateInstalled THEN
	Load_Plate_Motor.Enable := FALSE;
END_IF

bannerManager(
	baggerNotReady:= NOT UN00_SXMachine.unitModeManager.ActiveUnitMode.CurrentState = PACK_ML.State.Execute, 
	baggerReady:= UN00_SXMachine.unitModeManager.ActiveUnitMode.CurrentState = PACK_ML.State.Execute, 
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
	jawMotionFault:= , 
	waitingOnPrinter:= baggerCM.labelPrinter.waitingForPrinter, 
	waitingOnFiller:= , 
	batchCounterDone:= , 
	jawNotHomed:= NOT baggerCM.dualMotorPassthrough.IsHomed, 
	cycleBaggerTForFiller:= , 
	machineNotTested:= NOT Counters.baggerCycles.count >= 1000, 
	loadPlateMotorNotHomed:= NOT baggerCM.loadPlate.IsHomed AND baggerCM.loadPlate.OptionActive, 
	loadPlateMotorFaulted:= , 
	loadPlateMotorCommF:= , 
	topCoverLiftedFault:= topCoverLiftedFault.Active, 
	topCoverLiftedWarning:= iTopCoverClosed AND NOT HMIData.inCycle, 
	IBDMotorNotHomed:= NOT baggerCM.IBD.IsHomed AND baggerCM.IBD.OptionActive, 
	IBDMotorFaulted:= baggerCM.IBD.IBDMotorFault.Active, 
	IBDMotorCommF:= baggerCM.IBD.IBDMotorCommFault.Active, 
	printerRibbonFault := baggerCM.labelPrinter.ribbonFault.Active,
	printerServiceRequired := ,
	messageDisplayIndication=> HMIData.bannerMessageIndication);

HMIData.cycleTime := UN00_SXMachine.baggerManager.BaggerAutoMode.cycleTime;
HMIData.inCycle := UN00_SXMachine.baggerManager.BaggerAutoMode.cycleTimer.IN;

palmButton(
	baggerReady:= UN00_SXMachine.unitModeManager.ActiveUnitMode.CurrentState = PACK_ML.State.Execute, 
	baggerFaulted:= HMIData.faultActive, 
	baggerInCycle:= HMIData.inCycle, 
	palmState0Output=> oPalmButton0, 
	palmState1Output=> oPalmButton1);
	
amazonBPM(
	inCycle:= , 
	runtimeTimeout:= , 
	resetRuntime:= , 
	BPM=> , 
	BPMCycles=> , 
	BPMSeconds=> , 
	BPMIndication=> );