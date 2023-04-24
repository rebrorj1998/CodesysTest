(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK EM01_BaggerCM
VAR_INPUT
END_VAR
VAR_OUTPUT
	
	dummyVacuumCups : FB_BaseVacuum(name := 'Pneumatic Vacuum Cups') := (_optionEnabled := FALSE, _optionInstalled := FALSE);
	sealWire : FB_SealWire(name := 'Seal Wire') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	
	dummyBOF : FB_BaseBagOpenFingers(name := 'Dummy BOF') := (_optionEnabled := FALSE, _optionInstalled := FALSE);
	
	//singleMotorClampingPassthrough :  FB_SingleMotorPressureBar(name := 'Dual Motor Jaw') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	dualMotorPassthrough : FB_DualMotorPressureBar_Async(name := 'Dual Motor Jaw') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	dummySealFlatteners : FB_BaseSealFlatteners(name := 'Dummy Seal Flatteners') := (_optionEnabled := FALSE, _optionInstalled := FALSE); 
	
	jawFrontMotor : FB_AZDKAxis := (defaultCurrent := 100);
	//jawRearMotor : FB_AZDKAxis := (defaultCurrent := 100);
	
	clampingMechanism : FB_ClampingMechanism(name := 'Clamping Mechanism') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	
	printHeadActuator : FB_ElectricSolenoid(name := 'Print Head Actuator');
	labelPrinter : FB_ZebraPrinter(name := 'Zebra Label Printer') := (_optionEnabled := FALSE, _optionInstalled := TRUE);
	
	IBDMotor : FB_AZDKAxis := (DefaultCurrent := 100);
	IBD : FB_BaseIBD(name := 'Motorized IBD');
	
	barcodeVerifier : FB_BaseBCV(name := 'Barcode Verifier');
	
	bagDelivery : FB_1195BagDelivery(name := 'Bag Delivery');
	//bagDelivery : FB_SXBagDelivery(name := 'Bag Delivery');
	bagDeliveryFrontMotor : FB_AZDKAxis;	
END_VAR
VAR
	_axisCommsStatus : BOOL;
	_driveState : DED.DEVICE_STATE;
	oAxis3TargetPosition: DINT;
	
	homeSensorCTU : CTU;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

_driveState := AZD4A_KED.GetDeviceState();
_axisCommsStatus := NOT (_driveState <> DED.DEVICE_STATE.RUNNING);

jawFrontMotor(
	axisData := AxisData.jaw,
	commStatus := TRUE,
	iActualPosition := iFrontJawAxisPositionActualValue,
	iActualVelocity := iFrontJawAxisVelocityActualValue,
	iErrorCode := iFrontJawAxisErrorcode,
	iModeOfOperation := iFrontJawAxisModesOfOperationDisplay,
	iStatusword := iFrontJawAxisStatusword,
	oControlword => oFrontJawAxisControlword,
	oModeOfOperation => oFrontJawAxisModesOfOperation,
	oTargetPosition => oFrontJawAxisTargetPosition,
	oProfileAcceleration => oFrontJawAxisProfileAcceleration,
	oProfileDeceleration => oFrontJawAxisProfileDeceleration,
	oProfileVelocity => oFrontJawAxisProfileVelocity,
	oProfilePushCurrent => oFrontJawAxisPushCurrent,
	oProfileOperationalCurrent => oFrontJawAxisBaseCurrent,
	defaultCurrent := 100.0
);

homeSensorCTU(CU := iClampHomeSensor);

clampingMechanism(
	driveAlarm:= NOT iPbarClampMotorAlarm, 
	homeSensor:= iClampHomeSensor, 
	timeFromHomeToClamp:= T#500MS, 
	maximumClampingTime:= T#4.8S, 
	maximumReverseTime:= T#600MS,//T#540MS, 
	oStartMotor=> oPbarClampMotorStart, 
	oForwardMotor=> oPbarClampMotorReverse, 
	oResetDrive=> oPbarClampMotorAlarmReset, 
	maximumClampingTimeExceeded=> , 
	homeSensorNotSeen=> , 
	reversing=> , 
	state=> );

dualMotorPassthrough(
	frontMotor:= jawFrontMotor, 
	closeProfile:= AxisData.jawCloseMotionProfile, 
	openProfile:= AxisData.jawOpenMotionProfile,
	pushProfile := AxisData.jawPushMotionProfile ,
	moveInDelaySetting:= TO_TIME(HMIData.jawCloseDelay * 1000),
	passthroughSetting:= HMIData.passthroughSetting, 
	jawClosedSetting:= HMIData.jawClosePositionSetting, 
	clampingMechanism := clampingMechanism,
	//pressureBarClosedSensor:= iJawClosed, 
	//pressureBarNearClosedSensor:= iJawNearClosed, 
	obstructionSensor:= iJawNotObstructed, 
	openJawPB:= HMIData.jawService.extendCommand, 
	closeJawPB:= HMIData.jawService.retractCommand, 
	beginJawTestMode:= HMIData.startJawCycleTest,
	stopJawTestMode:= HMIData.stopJawCycleTest,
	actualPositionInInches=> HMIData.passthroughActual,
	currentTestCycles=> HMIData.jawClampTestCycles,
	jawTestModeActive => HMIData.jawCycleTestActive
);
dualMotorPassthrough.OptionInstalled := TRUE;
dualMotorPassthrough.OptionEnabled := TRUE;

labelPrinter(
	printSpeed:= HMIData.printSpeed, 
	printLength:= HMIData.printLength, 
	dataReadyInput:= iPrinterDataReady, 
	serviceRequiredInput:= iPrinterServiceRequired AND iTopCoverClosed, 
	endOfPrintInput:= iPrinterBusy,
	printHeadDownInput := oLowerPrinthead, 
	ribbonEncoderPulseInput:= iPrinterRibbonEncoder, 
	eStopOK := iTopCoverClosed,
	cancelPrint := HMIData.printerCancelRequest,
	serviceRaisePrintHead:= HMIData.printHeadService.retractCommand, 
	serviceLowerPrintHead:= HMIData.printHeadService.extendCommand,
	startPrintOutput=> oRequestPrint, 
	ribbonUnwindRunOutput=> oPrinterRibbonUnwind,
	lowerPrintHeadOutput=> oLowerPrintHead
);
labelPrinter.OptionInstalled := HMIData.printerInstalled;
labelPrinter.OptionEnabled := HMIData.printerInUse;
	
sealWire(simulateIO:= HMIData.simulateAllIO, sealDwell:= HMIData.sealBarDwell, sealCool := HMIData.sealBarCool , sealWireOutput=> oSealWire);	
	
IBDMotor( 
	axisData := AxisData.IBD,
	commStatus := _axisCommsStatus,
	jogForwardCMD := HMIData.IBDJogClosed,
	jogReverseCMD := HMIData.IBDJogOpen,
	iActualPosition := ,
	iActualVelocity := ,
	iModeOfOperation := ,
	iStatusword := ,
	oControlword => ,
	oModeOfOperation => ,
	oTargetPosition => ,
	oProfileAcceleration => ,
	oProfileDeceleration => ,
	oProfileVelocity => 
);

IBD(
	
);
IBD.OptionInstalled := HMIData.IBDInstalled;
IBD.OptionEnabled := HMIData.IBDInUse;

barcodeVerifier(
// 	feedSpeed := HMIData.printSpeed, 
// 	positionOffset := HMIData.barcodeStartPosition, 
// 	distanceToScan := HMIData.barcodeScanDistance, 
// 	iGoodRead := iBarcodeOK, 
// 	iBadRead := iBarcodeNG, 
// 	badReadFaultCountSetting := HMIData.barcodeBadReadFaultSetting, 
// 	triggerScanner => oTriggerBCV, 
// 	currentGoodReadCount => HMIData.barcodeGoodReadCount, 
// 	currentBadReadCount => HMIData.barcodeBadReadCount
);
barcodeVerifier.OptionInstalled := HMIData.barcodeVerifierInstalled;
barcodeVerifier.OptionEnabled := HMIData.barcodeVerifierInUse;	
	
bagDeliveryFrontMotor(
	axisData := AxisData.FilmFeed,
	commStatus := TRUE,
	iActualPosition := iFilmFeedAxisPositionActualValue,
	iActualVelocity := iFilmFeedAxisVelocityActualValue,
	iErrorCode := iFilmFeedAxisErrorcode,
	iModeOfOperation := iFilmFeedAxisModesOfOperationDisplay,
	iStatusword := iFilmFeedAxisStatusword,
	oControlword => oFilmFeedAxisControlword,
	oModeOfOperation => oFilmFeedAxisModesOfOperation,
	oTargetPosition => oFilmFeedAxisTargetPosition,
	oProfileAcceleration => oFilmFeedAxisProfileAcceleration,
	oProfileDeceleration => oFilmFeedAxisProfileDeceleration,
	oProfileVelocity => oFilmFeedAxisProfileVelocity,
	oProfilePushCurrent => oFilmFeedAxisPushCurrent,
	oProfileOperationalCurrent => oFilmFeedAxisBaseCurrent,
	defaultCurrent := 100.0
);
bagDelivery(
	printer:= PLC_PRG_1.EM01_SXBaggerHead.printer, 
	bagLength:= HMIData.bagLength, 
	feedSpeed:= TO_REAL(HMIData.bagForwardSpeed), 
	reverseSpeed:= TO_REAL(HMIData.bagReverseSpeed), 
	printSpeed:= TO_REAL(HMIData.printSpeed), 
	printOffset:= HMIData.printOffset, 
	printLength:= HMIData.printLength, 
	maxReverseSetpoint:= 4.0, 
	sealOffset:= HMIData.bagSkirtLength, 
	distanceFromSealBarToBagEdge:= GlobalData.SEAL_TO_PHOTOEYE_DISTANCE, 
	distanceFromNipToBagEdge:= , 
	bagPresent:= iBagEdgePhotoeye,  
	bagDeliveryMotor:= bagDeliveryFrontMotor
);
bagDelivery.OptionInstalled := TRUE;
bagDelivery.OptionEnabled := TRUE;		
