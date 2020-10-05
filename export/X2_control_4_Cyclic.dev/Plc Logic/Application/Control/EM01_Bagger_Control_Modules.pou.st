(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK EM01_Bagger_Control_Modules
VAR_INPUT
END_VAR
VAR_OUTPUT
	
	dummyVacuumCups : FB_BaseVacuum(name := 'Pneumatic Vacuum Cups') := (_optionEnabled := FALSE, _optionInstalled := FALSE);
	simExitConveyor : FB_SimBasicExitConveyor(name := 'Sim Exit Conveyor') := (_optionEnabled := FALSE, _optionInstalled := FALSE);
	standardBagOpenFingersWithSensors : FB_BaseBagOpenFingers(name := 'Standard Bag Open Fingers') := (_optionEnabled := FALSE, _optionInstalled := FALSE);
	sealWire : FB_SealWire(name := 'Seal Wire') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	dummyBOF : FB_BaseBagOpenFingers(name := 'Dummy BOF');

	dualMotorPassthrough : FB_DualMotorPBar(name := 'Dual Motor Jaw') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	dummySealFlatteners : FB_BaseSealFlatteners(name := 'Dummy Seal Flatteners') := (_optionEnabled := FALSE, _optionInstalled := FALSE); 
	
	jawFrontMotor : FB_OrientalAZMotorTriggerPositionTest := (DefaultCurrent := 100);
	jawRearMotor : FB_OrientalAZMotorTriggerPositionTest := (DefaultCurrent := 100);
	jawBothMotors : FB_OrientalAZMotorTriggerPositionTest := (DefaultCurrent := 100);
	bagOpenFingersActuator : FB_PneumaticVerticalActuator(name := 'Bag Open Fingers Actuator');
	sealFlattenerVertAxisActuator : FB_DummyUpDown;
	
	labelPrinter : FB_ZebraPrinter(name := 'Zebra Label Printer') := (_optionEnabled := FALSE, _optionInstalled := TRUE);
	printHeadActuator : FB_ElectricSolenoid(name := 'Print Head Actuator');
	
	IBDMotor : FB_OrientalAZMotorTriggerPositionTest() := (DefaultCurrent := 100);
	IBD : FB_MotorizedIBD(name := 'Motorized IBD');
	
	loadPlateMotor : FB_OrientalAZMotorTriggerPositionTest() := (DefaultCurrent := 100);

	loadPlate : FB_MotorizedLoadPlate(name := 'Motorized Load Plate');
	
	barcodeVerifier : FB_BaseBCV(name := 'Barcode Verifier');
	
	bagDelivery : FB_SXBagDelivery(name := 'Bag Delivery') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	bagDeliveryFrontMotor : FB_AppliedMotionMotorModbus;
	
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

simExitConveyor(_optionActive=> );

jawFrontMotor(
	stepsPerInchSP:= Globals.STEPS_PER_INCH_JAW, 
	zeroOffset:= HMIData.jawZeroOffset,  
	positionPresetRequest := HMIData.frontJawMotorData.setPreset,
	freeMotorRequest := HMIData.frontJawMotorData.freeMotor,
	MBChannel:= Front_Jaw_Motor, 
	modbusDataFromDrive:= frontJawMotorInputs, 
	modbusDirectDataToDrive:= frontJawMotorDDOutputs, 
	modbusRIODataToDrive:= frontJawMotorRIOOutputs,
	triggerDDWriteNow => frontJawMotorDDTrigger,
	triggerRIOWriteNow => frontJawMotorRIOTrigger);

jawRearMotor(
	stepsPerInchSP:= Globals.STEPS_PER_INCH_JAW, 
	zeroOffset:= HMIData.jawZeroOffset, 
	positionPresetRequest := HMIData.rearJawMotorData.setPreset,
	freeMotorRequest := HMIData.rearJawMotorData.freeMotor,
	MBChannel:= Rear_Jaw_Motor, 
	modbusDataFromDrive:= rearJawMotorInputs, 
	modbusDirectDataToDrive:= rearJawMotorDDOutputs, 
	modbusRIODataToDrive:= rearJawMotorRIOOutputs,
	triggerDDWriteNow => rearJawMotorDDTrigger,
	triggerRIOWriteNow => rearJowMotorRIOTrigger);

jawBothMotors( 
	DefaultCurrent:= 100, 
	isGroup:= TRUE, 
	stepsPerInchSP:= Globals.STEPS_PER_INCH_JAW, 
	zeroOffset:= HMIData.jawZeroOffset, 
	jogForwardCMD:= HMIData.jawjobClosed, 
	jogReverseCMD:= HMIData.jawJogOpen, 
	groupMotor0:= jawFrontMotor, 
	groupMotor1:= jawRearMotor, 
	MBChannel:= Both_Jaw_Motors, 
	modbusDataFromDrive:= bothJawMotorInputs, 
	modbusDirectDataToDrive:= bothJawMotorDDOutputs, 
	modbusRIODataToDrive:= bothJawMotorRIOOutputs,
	triggerDDWriteNow => bothJawMotorDDTrigger,
	triggerRIOWriteNow => bothJawMotorRIOTrigger);

dualMotorPassthrough(
	frontMotor:= jawFrontMotor, 
	rearMotor:= jawRearMotor, 
	bothMotors:= jawBothMotors, 
	closeVelo:= HMIData.jawCloseMotionProfile.velo, 
	closeAccel:= HMIData.jawCloseMotionProfile.accel, 
	closeDecel:= HMIData.jawCloseMotionProfile.decel, 
	openVelo:= HMIData.jawOpenMotionProfile.velo, 
	openAccel:= HMIData.jawOpenMotionProfile.accel, 
	openDecel:= HMIData.jawOpenMotionProfile.decel, 
	moveInDelaySetting := TO_TIME(HMIData.jawCloseDelay * 1000),
	passthroughSetting:= HMIData.passthroughSetting, 
	jawClosedSetting:= HMIData.jawClosePositionSetting, 
	pressureBarClosedSensor:= iJawClosed, 
	pressureBarNearClosedSensor:= iJawNearClosed, 
	obstructionSensor:= iJawNotObstructed, 
	openJawPB:= HMIData.jawService.extendCommand, 
	closeJawPB:= HMIData.jawService.retractCommand, 
	beginJawTestMode := HMIData.startJawCycleTest,
	stopJawTestMode := HMIData.stopJawCycleTest,
	actualPosition=> HMIData.passthroughActual,
	currentTestCycles => HMIData.jawCycleTestCycles,
	jawTestModeActive => HMIData.jawCycleTestActive);

labelPrinter(
	dryCycleEnable := HMIData.dryCycleEnable,
	printSpeed:= HMIData.printSpeed, 
	printLength:= HMIData.printLength, 
	dataReadyInput:= iPrinterDataReady, 
	serviceRequiredInput:= iPrinterServiceRequired AND iTopCoverClosed, 
	endOfPrintInput:= iPrinterBusy,
	printHeadDownInput := iPrintHeadLowered, 
	ribbonEncoderPulseInput:= iPrinterRibbonEncoder, 
	eStopOK := iTopCoverClosed,
	cancelPrint := HMIData.printerCancelRequest,
	serviceRaisePrintHead:= HMIData.printHeadService.retractCommand, 
	serviceLowerPrintHead:= HMIData.printHeadService.extendCommand,
	startPrintOutput=> oRequestPrint, 
	ribbonUnwindRunOutput=> oPrinterRibbonUnwind,
	lowerPrintHeadOutput=> oLowerPrintHead);
	
sealWire(simulateIO:= HMIData.simulateAllIO, sealDwell:= HMIData.sealBarDwell, sealCool := HMIData.sealBarCool , sealWireOutput=> oSealWire);	

standardBagOpenFingersWithSensors();
sealFlattenerVertAxisActuator();
dummySealFlatteners();

IBDMotor(
	DefaultCurrent:= 100, 
	stepsPerInchSP:= Globals.STEPS_PER_INCH_IBD, 
	zeroOffset:= HMIData.IBDZeroOffset, 
	jogForwardCMD:= HMIData.IBDJogClosed, 
	jogReverseCMD:= HMIData.IBDJogOpen, 
	positionPresetRequest := HMIData.IBDMotorData.setPreset,
	freeMotorRequest := HMIData.IBDMotorData.freeMotor,
	MBChannel:= IBD_Motor, 
	modbusDataFromDrive:= IBDMotorInputs, 
	modbusDirectDataToDrive:= IBDMotorDDOutputs, 
	modbusRIODataToDrive:= IBDMotorRIOOutputs,
	triggerDDWriteNow => IBDMotorDDTRigger,
	triggerRIOWriteNow => IBDMotorRIOTRigger);
IBD(
	closeVelo:= HMIData.IBDCloseMotionProfile.velo, 
	closeAccel:= HMIData.IBDCloseMotionProfile.accel, 
	closeDecel:= HMIData.IBDCloseMotionProfile.decel, 
	closeCurrent:= HMIData.IBDCloseMotionProfile.current, 
	openVelo:= HMIData.IBDOpenMotionProfile.velo, 
	openAccel:= HMIData.IBDOpenMotionProfile.accel, 
	openDecel:= HMIData.IBDOpenMotionProfile.decel, 
	passthroughSetting:= HMIData.passthroughSetting,  
	openIBDPB:= HMIData.IBDService.extendCommand, 
	closeIBDPB:= HMIData.IBDService.retractCommand,  
	IBDMotor:= IBDMotor);

loadPlateMotor( 
	stepsPerInchSP:= Globals.STEPS_PER_INCH_LOAD_PLATE, 
	positionPresetRequest := HMIData.loadPlateMotorData.setPreset,
	freeMotorRequest := HMIData.loadPlateMotorData.freeMotor,
	MBChannel:= Load_Plate_Motor, 
	modbusDataFromDrive:= loadPlateMotorInputs, 
	modbusDirectDataToDrive:= loadPlateMotorDDOutputs, 
	modbusRIODataToDrive:= loadPlateMotorRIOOutputs,
	triggerDDWriteNow => loadPlateMotorDDTrigger,
	triggerRIOWriteNow => loadPlateMotorRIOTrigger);
	
loadPlate(
	lowerVelo:= HMIData.loadPlateLowerProfile.velo, 
	lowerAccel:= HMIData.loadPlateLowerProfile.accel, 
	lowerDecel:= HMIData.loadPlateLowerProfile.decel, 
	raiseVelo:= HMIData.loadPlateRaiseProfile.velo, 
	raiseAccel:= HMIData.loadPlateRaiseProfile.accel, 
	raiseDecel:= HMIData.loadPlateRaiseProfile.decel,
	raisedSetting:= HMIData.loadPlateRaisedPositionSetting, 
	loweredSetting:= HMIData.loadPlateLoweredPositionSetting, 
	dwellSetting:= HMIData.loadPlateDwell, 
	raiseShelfPB:= HMIData.loadPlateService.extendCommand, 
	lowerShelfPB:= HMIData.loadPlateService.retractCommand, 
	loadPlateMotor:= loadPlateMotor);

barcodeVerifier(
	dryCycleEnable := HMIData.dryCycleEnable,
	feedSpeed:= HMIData.printSpeed, 
	positionOffset:= HMIData.barcodeStartPosition, 
	distanceToScan:= HMIData.barcodeScanDistance, 
	readGoodInput:= iBarcodeOK, 
	badReadInput:= iBarcodeNG, 
	badReadFaultCountSetting:= HMIData.barcodeBadReadFaultSetting, 
	triggerScannerOutput=> oTriggerBCV, 
	currentGoodReadCount=> HMIData.barcodeGoodReadCount, 
	currentBadReadCount=> HMIData.barcodeBadReadCount);	

bagDeliveryFrontMotor(
	stepsPerInchSP:= Globals.STEPS_PER_INCH_FILM, 
	jogForwardCMD:= HMIData.jogFilmForward, 
	jogReverseCMD:= HMIData.jogFilmReverse);
	
bagDelivery(
	simulateIO := HMIData.simulateAllIO,
	dryCycleEnable := HMIData.dryCycleEnable,
	printer:= PLC_PRG.baggerCM.labelPrinter, 
	bagLength:= HMIData.bagLength, 
	feedSpeed:= TO_REAL(HMIData.bagForwardSpeed), 
	reverseSpeed:= TO_REAL(HMIData.bagReverseSpeed), 
	printSpeed:= TO_REAL(HMIData.printSpeed), 
	printOffset:= HMIData.printOffset, 
	printLength:= HMIData.printLength, 
	maxReverseSetpoint:= 4.0, 
	sealOffset:= HMIData.bagSkirtLength, 
	distanceFromSealBarToBagEdge:= Globals.SEAL_TO_PHOTOEYE_DISTANCE, 
	bagPresent:= iBagEdgePhotoeye,  
	bagDeliveryMotor:= bagDeliveryFrontMotor);	
	
IBD.OptionInstalled := HMIData.IBDInstalled;
IBD.OptionEnabled := HMIData.IBDInUse;

labelPrinter.OptionInstalled := HMIData.printerInstalled;
labelPrinter.OptionEnabled := HMIData.printerInUse;

loadPlate.OptionInstalled := HMIData.loadPlateInstalled;
loadPlate.OptionEnabled := HMIData.loadPlateInUse;

barcodeVerifier.OptionInstalled := HMIData.barcodeVerifierInstalled;
barcodeVerifier.OptionEnabled := HMIData.barcodeVerifierInUse;
