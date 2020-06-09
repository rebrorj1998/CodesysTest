(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK EM01_Bagger_Control_Modules
VAR_INPUT
END_VAR
VAR_OUTPUT
	//simBagDelivery : FB_SimBasicBagDelivery(name := 'Sim Bag Delivery'):= (enable := TRUE, installed := TRUE);
	//simPrinter : FB_SimBasicPrinter(name := 'Sim Printer'):= (enable := TRUE, installed := TRUE);
	//simVacuumCups : FB_SimBasicVacuum(name := 'Sim Vac Cups') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	dummyVacuumCups : FB_BaseVacuum(name := 'Pneumatic Vacuum Cups') := (_optionEnabled := FALSE, _optionInstalled := FALSE);
	//simLoadPlate : FB_SimBasicLoadPlate(name := 'Sim Load Plate') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	simExitConveyor : FB_SimBasicExitConveyor(name := 'Sim Exit Conveyor') := (_optionEnabled := FALSE, _optionInstalled := FALSE);
	standardBagOpenFingersWithSensors : FB_BaseBagOpenFingers(name := 'Standard Bag Open Fingers') := (_optionEnabled := FALSE, _optionInstalled := FALSE);
	sealWire : FB_SealWire(name := 'Seal Wire') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	dummyBOF : FB_BaseBagOpenFingers(name := 'Dummy BOF');
	
	dualMotorPassthrough : FB_DualMotorPBar(name := 'Dual Motor Jaw') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	dummySealFlatteners : FB_BaseSealFlatteners(name := 'Dummy Seal Flatteners') := (_optionEnabled := FALSE, _optionInstalled := FALSE); 
	
	//jawFrontMotor : FB_OrientalAZMotor;
	//jawRearMotor : FB_OrientalAZMotor;
	//jawBothMotors : FB_OrientalAZMotor;
	jawFrontMotor : FB_SimMotor;
	jawRearMotor : FB_SimMotor;
	jawBothMotors : FB_SimMotor;
	bagOpenFingersActuator : FB_PneumaticVerticalActuator(name := 'Bag Open Fingers Actuator');
	sealFlattenerVertAxisActuator : FB_PneumaticVerticalActuator(name := 'Seal Flat Pneu Vert Axis Actuator');
	
	bagDelivery : FB_SXBagDelivery(name := 'Bag Delivery') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	//bagDeliveryFrontMotor : FB_AppliedMotionMotorMB;
	bagDeliveryFrontMotor : FB_SimMotor;
	labelPrinter : FB_ZebraPrinter(name := 'Zebra Label Printer') := (_optionEnabled := FALSE, _optionInstalled := TRUE);
	printHeadActuator : FB_ElectricSolenoid(name := 'Print Head Actuator');
	
	//IBDMotor : FB_OrientalAZMotor() := (DefaultCurrent := 100);
	IBDMotor : FB_SimMotor();
	IBD : FB_MotorizedIBD(name := 'Motorized IBD');
	
	//loadPlateMotor : FB_OrientalAZMotor() := (DefaultCurrent := 100);
	loadPlateMotor : FB_SimMotor;
	loadPlate : FB_MotorizedLoadPlate(name := 'Motorized Load Plate');
	
	barcodeVerifier : FB_BaseBCV(name := 'Barcode Verifier');
END_VAR

VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// simBagDelivery(
// 	enable:= , 
// 	installed:= , 
// 	active=> , 
// 	feedSpeed:= HMIData.bagForwardSpeed, 
// 	reverseSpeed:= HMIData.bagReverseSpeed, 
// 	printSpeed:= HMIData.printSpeed, 
// 	printLength:= HMIData.printLength, 
// 	bagLength:= HMIData.bagLength, 
// 	reverseLength:= 2.0, 
// 	printOffset:= HMIData.printOffset);
	
//sealFlattenerPneuVerticalAxis(cylinder := sealFlattenerVertAxisActuator);

simExitConveyor(_optionActive=> );

// jawBothMotors(
// 	AxisState:= , 
// 	SetOpMode:= , 
// 	PowerOn:= , 
// 	DriveEnable:= , 
// 	AckError:= , 
// 	StartHoming:= , 
// 	Halt:= , 
// 	NewSetPoint:= , 
// 	MoveAbs:= , 
// 	MoveAbsTorque:= , 
// 	MoveRel:= , 
// 	MoveVelo:= , 
// 	TargetPosDist:= , 
// 	TargetVelocity:= , 
// 	ProfileVelocity:= , 
// 	ProfileAcceleration:= , 
// 	ProfileDeceleration:= , 
// 	ProfileCurrentLimit:= , 
// 	QuickStopDeceleration:= , 
// 	DefaultCurrent:= 100, 
// 	ActOpMode=> , 
// 	CommStatus=> , 
// 	PowerState=> , 
// 	EnableState=> , 
// 	Error=> , 
// 	ActPos=> , 
// 	ActVelocity=> , 
// 	SetPointAck=> , 
// 	TargetReached=> , 
// 	InVelocity=> , 
// 	HomingDone=> , 
// 	modbusAddress:= 1, 
// 	isGroup:= TRUE, 
// 	stepsPerInchSP:= 3999, 
// 	zeroOffset:= , 
// 	jogForwardCMD:= HMIData.jawJogOpen, 
// 	jogReverseCMD:= HMIData.jawjobClosed, 
// 	groupMotor0:= jawFrontMotor, 
// 	groupMotor1:= jawRearMotor, 
// 	MBChannel:= TestMotorSlave, 
// 	modbusDataFromDrive:= testMotorInputs, 
// 	modbusDirectDataToDrive:= testMotorDDOutputs, 
// 	modbusRIODataToDrive:= testMotorRIOOutputs);

jawFrontMotor();
jawRearMotor();
jawBothMotors();
dualMotorPassthrough(
	simulateIO:= , 
	frontMotor:= jawFrontMotor, 
	rearMotor:= jawRearMotor, 
	bothMotors:= jawBothMotors, 
	closeVelo:= HMIData.jawCloseMotionProfile.velo, 
	closeAccel:= HMIData.jawCloseMotionProfile.accel, 
	closeDecel:= HMIData.jawCloseMotionProfile.decel, 
	openVelo:= HMIData.jawOpenMotionProfile.velo, 
	openAccel:= HMIData.jawOpenMotionProfile.accel, 
	openDecel:= HMIData.jawOpenMotionProfile.decel, 
	homeTimeoutSetting:= , 
	passthroughSetting:= HMIData.passthroughSetting, 
	jawClosedSetting:= HMIData.jawClosePositionSetting, 
	pressureBarClosedSensor:= iJawClosed, 
	pressureBarNearClosedSensor:= iJawNearClosed, 
	obstructionSensor:= iJawNotObstructed, 
	openJawPB:= HMIData.jawService.extendCommand, 
	closeJawPB:= HMIData.jawService.retractCommand, 
	failedToClose=> , 
	failedToOpen=> , 
	failedToHome=> , 
	pressureBarObstructed=> , 
	frontMotorFault=> , 
	frontMotorCommFault=> , 
	rearMotorFault=> , 
	rearMotorCommFault=> , 
	actualPosition=> HMIData.passthroughActual);


	
labelPrinter(
	simulateIO:= , 
	printSpeed:= HMIData.printSpeed, 
	printLength:= HMIData.printLength, 
	printHeadDebounceSetting:= , 
	dataReadyInput:= iPrinterDataReady, 
	serviceRequiredInput:= , 
	ribbonLowInput:= , 
	endOfPrintInput:= iPrinterBusy,
	printHeadDownInput := iPrintHeadLowered, 
	ribbonEncoderPulseInput:= iPrinterRibbonEncoder, 
	serviceRaisePrintHead:= HMIData.printHeadService.retractCommand, 
	serviceLowerPrintHead:= HMIData.printHeadService.extendCommand, 
	serviceRequired=> , 
	ribbonFault=> ,
	printHeadFailToLower=> ,
	printHeadDebounced=> , 
	startPrintOutput=> oRequestPrint, 
	ribbonUnwindRunOutput=> oPrinterRibbonUnwind,
	lowerPrintHeadOutput=> oLowerPrintHead);
	

sealWire(simulateIO:= HMIData.simulateAllIO, sealDwell:= HMIData.sealBarDwell, sealWireOutput=> oSealWire);	


//vacuumCups(_optionActive=>, vacGenerator := Devices.vacuumSolenoidValve);	
//bagOpenFingersActuator(cylinder:= Devices.bagOpenFingersSolenoidValve);

standardBagOpenFingersWithSensors(
	delayToGrabSetting:= , 
	delayToCheckBagPresentSetting:= , 
	delayToClearSetting:= , 
	grabCounter=> , 
	releaseCounter=> , 
	missedCounter=> );


sealFlattenerVertAxisActuator(solenoid0=> , solenoid1=> , cylinder:= Devices.sealFlattenersVertAxisSolenoidValve);
dummySealFlatteners();
	
bagDeliveryFrontMotor();
// bagDeliveryFrontMotor(
// 	AxisState:= , 
// 	SetOpMode:= , 
// 	PowerOn:= , 
// 	DriveEnable:= , 
// 	AckError:= , 
// 	StartHoming:= , 
// 	Halt:= , 
// 	NewSetPoint:= , 
// 	MoveAbs:= , 
// 	MoveAbsTorque:= , 
// 	MoveRel:= , 
// 	MoveVelo:= , 
// 	TargetPosDist:= , 
// 	TargetVelocity:= , 
// 	ProfileVelocity:= , 
// 	ProfileAcceleration:= , 
// 	ProfileDeceleration:= , 
// 	ProfileCurrentLimit:= , 
// 	QuickStopDeceleration:= , 
// 	DefaultCurrent:= , 
// 	ActOpMode=> , 
// 	CommStatus=> , 
// 	PowerState=> , 
// 	EnableState=> , 
// 	Error=> , 
// 	ActPos=> , 
// 	ActVelocity=> , 
// 	SetPointAck=> , 
// 	TargetReached=> , 
// 	InVelocity=> , 
// 	HomingDone=> , 
// 	modbusAddress:= , 
// 	stepsPerInchSP:= , 
// 	zeroOffset:= , 
// 	jogForwardCMD:= , 
// 	jogReverseCMD:= , 
// 	MBChannel:= Film_Feed_Drive, 
// 	modbusDataFromDrive:= filmFeedInputs, 
// 	modbusParDataToDrive:= filmFeedWritePars, 
// 	modbusOpcodeToDrive:= filmFeedWriteOpcode);	
	
bagDelivery(
	simulateIO := HMIData.simulateAllIO,
	_optionActive=> , 
	printer:= labelPrinter, 
	bagLength:= HMIData.bagLength, 
	feedSpeed:= TO_REAL(HMIData.bagForwardSpeed), 
	reverseSpeed:= TO_REAL(HMIData.bagReverseSpeed), 
	printSpeed:= TO_REAL(HMIData.printSpeed), 
	printOffset:= HMIData.printOffset, 
	printLength:= HMIData.printLength, 
	maxReverseSetpoint:= 4.0, 
	sealOffset:= HMIData.bagSkirtLength, 
	distanceFromSealBarToBagEdge:= , 
	distanceFromNipToBagEdge:= , 
	bagPhotoeyeInput:= iBagEdgePhotoeye, 
	trapezoidalPercent:= , 
	reverseFault=> , 
	bagFailedToSeparate=> , 
	bagDeliveryMotor:= bagDeliveryFrontMotor);
	
IBDMotor();
// IBDMotor(
// 	AxisState:= , 
// 	SetOpMode:= , 
// 	PowerOn:= , 
// 	DriveEnable:= , 
// 	AckError:= , 
// 	StartHoming:= , 
// 	Halt:= , 
// 	NewSetPoint:= , 
// 	MoveAbs:= , 
// 	MoveAbsTorque:= , 
// 	MoveRel:= , 
// 	MoveVelo:= , 
// 	TargetPosDist:= , 
// 	TargetVelocity:= , 
// 	ProfileVelocity:= , 
// 	ProfileAcceleration:= , 
// 	ProfileDeceleration:= , 
// 	ProfileCurrentLimit:= , 
// 	QuickStopDeceleration:= , 
// 	DefaultCurrent:= , 
// 	ActOpMode=> , 
// 	CommStatus=> , 
// 	PowerState=> , 
// 	EnableState=> , 
// 	Error=> , 
// 	ActPos=> , 
// 	ActVelocity=> , 
// 	SetPointAck=> , 
// 	TargetReached=> , 
// 	InVelocity=> , 
// 	HomingDone=> , 
// 	modbusAddress:= , 
// 	isGroup:= , 
// 	stepsPerInchSP:= Globals.STEPS_PER_INCH_IBD, 
// 	zeroOffset:= , 
// 	jogForwardCMD:= HMIData.IBDJogOpen, 
// 	jogReverseCMD:= HMIData.IBDJogClosed, 
// 	groupMotor0:= , 
// 	groupMotor1:= , 
// 	MBChannel:= IBD_Motor, 
// 	modbusDataFromDrive:= IBDMotorInputs, 
// 	modbusDirectDataToDrive:= IBDMotorDDOutputs, 
// 	modbusRIODataToDrive:= IBDMotorRIOOutputs);
	
IBD(
	closeVelo:= HMIData.IBDCloseMotionProfile.velo, 
	closeAccel:= HMIData.IBDCloseMotionProfile.accel, 
	closeDecel:= HMIData.IBDCloseMotionProfile.decel, 
	closeCurrent:= HMIData.IBDCloseMotionProfile.current, 
	openVelo:= HMIData.IBDOpenMotionProfile.velo, 
	openAccel:= HMIData.IBDOpenMotionProfile.accel, 
	openDecel:= HMIData.IBDOpenMotionProfile.decel, 
	homeTimeoutSetting:= , 
	passthroughSetting:= HMIData.passthroughSetting, 
	jawClosedSetting:= , 
	openIBDPB:= HMIData.IBDService.extendCommand, 
	closeIBDPB:= HMIData.IBDService.retractCommand, 
	failedToOpen=> , 
	failedToHome=> , 
	IBDMotorFault=> , 
	IBDMotorCommFault=> , 
	actualPosition=> , 
	IBDMotor:= IBDMotor);
loadPlateMotor();
// loadPlateMotor(
// 	AxisState:= , 
// 	SetOpMode:= , 
// 	PowerOn:= , 
// 	DriveEnable:= , 
// 	AckError:= , 
// 	StartHoming:= , 
// 	Halt:= , 
// 	NewSetPoint:= , 
// 	MoveAbs:= , 
// 	MoveAbsTorque:= , 
// 	MoveRel:= , 
// 	MoveVelo:= , 
// 	TargetPosDist:= , 
// 	TargetVelocity:= , 
// 	ProfileVelocity:= , 
// 	ProfileAcceleration:= , 
// 	ProfileDeceleration:= , 
// 	ProfileCurrentLimit:= , 
// 	QuickStopDeceleration:= , 
// 	DefaultCurrent:= , 
// 	ActOpMode=> , 
// 	CommStatus=> , 
// 	PowerState=> , 
// 	EnableState=> , 
// 	Error=> , 
// 	ActPos=> , 
// 	ActVelocity=> , 
// 	SetPointAck=> , 
// 	TargetReached=> , 
// 	InVelocity=> , 
// 	HomingDone=> , 
// 	modbusAddress:= , 
// 	isGroup:= , 
// 	stepsPerInchSP:= 1, 
// 	zeroOffset:= , 
// 	jogForwardCMD:= , 
// 	jogReverseCMD:= , 
// 	groupMotor0:= , 
// 	groupMotor1:= , 
// 	MBChannel:= Load_Plate_Motor, 
// 	modbusDataFromDrive:= loadPlateMotorInputs, 
// 	modbusDirectDataToDrive:= loadPlateMotorDDOutputs, 
// 	modbusRIODataToDrive:= loadPlateMotorRIOOutputs);
	
loadPlate(
	lowerVelo:= HMIData.loadPlateLowerProfile.velo, 
	lowerAccel:= HMIData.loadPlateLowerProfile.accel, 
	lowerDecel:= HMIData.loadPlateLowerProfile.decel, 
	raiseVelo:= HMIData.loadPlateRaiseProfile.velo, 
	raiseAccel:= HMIData.loadPlateRaiseProfile.accel, 
	raiseDecel:= HMIData.loadPlateRaiseProfile.decel,
	homeTimeoutSetting:= , 
	raisedSetting:= HMIData.loadPlateRaisedPositionSetting, 
	loweredSetting:= HMIData.loadPlateLoweredPositionSetting, 
	dwellSetting:= HMIData.loadPlateDwell, 
	raiseShelfPB:= HMIData.loadPlateService.extendCommand, 
	lowerShelfPB:= HMIData.loadPlateService.retractCommand, 
	failedToHome=> , 
	motorFault=> , 
	motorCommFault=> , 
	actualPosition=> , 
	loadPlateMotor:= loadPlateMotor);

barcodeVerifier(
	feedSpeed:= HMIData.printSpeed, 
	positionOffset:= HMIData.barcodeStartPosition, 
	distanceToScan:= HMIData.barcodeScanDistance, 
	readGoodInput:= iBarcodeOK, 
	badReadInput:= iBarcodeNG, 
	badReadFaultCountSetting:= HMIData.barcodeBadReadFaultSetting, 
	triggerScannerOutput=> oTriggerBCV, 
	xBusy=> , 
	xDone=> , 
	currentGoodReadCount=> HMIData.barcodeGoodReadCount, 
	currentBadReadCount=> HMIData.barcodeBadReadCount, 
	barcodeFault=> );	

IBD.OptionInstalled := HMIData.IBDInstalled;
IBD.OptionEnabled := HMIData.IBDInUse;

labelPrinter.OptionInstalled := HMIData.printerInstalled;
labelPrinter.OptionEnabled := HMIData.printerInUse;

loadPlate.OptionInstalled := HMIData.loadPlateInstalled;
loadPlate.OptionEnabled := HMIData.loadPlateInUse;

barcodeVerifier.OptionInstalled := HMIData.barcodeVerifierInstalled;
barcodeVerifier.OptionEnabled := HMIData.barcodeVerifierInUse;
