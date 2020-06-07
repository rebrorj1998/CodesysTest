(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK EM01_Bagger_Control_Modules
VAR_INPUT
END_VAR
VAR_OUTPUT
	
	
	
	//simBagDelivery : FB_SimBasicBagDelivery(name := 'Sim Bag Delivery'):= (enable := TRUE, installed := TRUE);
	//simPrinter : FB_SimBasicPrinter(name := 'Sim Printer'):= (enable := TRUE, installed := TRUE);
	//simVacuumCups : FB_SimBasicVacuum(name := 'Sim Vac Cups') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	vacuumCups : FB_PneumaticVacuumCups(name := 'Pneumatic Vacuum Cups') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	simLoadPlate : FB_SimBasicLoadPlate(name := 'Sim Load Plate') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	simExitConveyor : FB_SimBasicExitConveyor(name := 'Sim Exit Conveyor') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	
	standardSealBar : FB_PneumaticSealer(name := 'Pneumatic Seal Bar') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	standardBagOpenFingersWithSensors : FB_PneuBagOpenFingersWithSensorsOLD(name := 'Standard Bag Open Fingers') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	pneumaticPressureBar : FB_PneuPBarWithAdjPass(name := 'Pneumatic Pressure Bar') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	motorizedSealFlatteners : FB_MotorizedSealFlatteners(name := 'Motorized Seal Flatteners') := (_optionEnabled := TRUE, _optionInstalled := TRUE); 
	
	passthroughMotor : FB_SimMotor;
	msfHorizontalMotor : FB_SimMotor;
	bagOpenFingersActuator : FB_PneumaticVerticalActuator(name := 'Bag Open Fingers Actuator');
	sealFlattenerVertAxisActuator : FB_PneumaticVerticalActuator(name := 'Seal Flat Pneu Vert Axis Actuator');
	
	bagDelivery : FB_Pro18BagDelivery(name := 'Bag Delivery') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	bagDeliveryFrontMotor : FB_SimMotor;
	
	labelPrinter : FB_Pro18ZebraPrinter(name := 'Zebra Label Printer') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	printHeadActuator : FB_PneumaticVerticalActuator(name := 'Print Head Actuator');
	

	
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

simLoadPlate(_optionActive=> , loadPlateDwell:= HMIData.loadPlateDwell);

passthroughMotor(simFault := UN00_Globals.simFaults.passthroughMotorFault);

pneumaticPressureBar(
	_optionActive=> , 
	simulateIO:= HMIData.simulateAllIO, 
	passthroughMotor:= passthroughMotor, 
	cylinder := Devices.pressureBarSolenoidValve,
	ptVelo:= , 
	ptAccel:= , 
	ptDecel:= , 
	homeTimeoutSetting:= ,
	passthroughSetting := HMIData.passthroughSetting, 
	failedToClose=> , 
	failedToOpen=> , 
	failedToHome=> , 
	pressureBarObstructed=> , 
	motorFault=> , 
	failedToMovePassthrough=> , 
	actualPassthrough=> HMIData.passthroughActual, 
	PressureBarClosedSensor:= IO.iPressureBarRetracted, 
	PressureBarOpenSensor:= IO.iPressureBarExtended,
	ObstructionSensor := IO.iPressureBarNotObstructed);

printHeadActuator(cylinder := Devices.printHeadSolenoidValve);
labelPrinter(
	_optionActive=> , 
	simulateIO:= HMIData.simulateAllIO, 
	printSpeed:= HMIData.printSpeed, 
	printLength:= HMIData.printLength, 
	printHead:= printHeadActuator, 
	dataReadyInput:= IO.iPrinterDataReady, 
	serviceRequiredInput:= IO.iPrinterServiceRequired, 
	ribbonLowInput:= IO.iPrinterRibbonOut, 
	endOfPrintInput:= IO.iPrinterEndOfPrint, 
	printHeadDebounceSetpoint:= , 
	serviceRequired=> , 
	ribbonLow=> , 
	startPrintOutput:= IO.oPrinterStartPrint, 
	ribbonUnwindRunOutput:= IO.oRunRibbonUnwindMotor);
	
standardSealBar( 
	_optionActive=> , 
	simulateIO:= HMIData.simulateAllIO, 
	sealDwell:= HMIData.sealBarDwell, 
	cylinder:= Devices.sealBarSolenoidValve);
	


vacuumCups(_optionActive=>, vacGenerator := Devices.vacuumSolenoidValve);	
bagOpenFingersActuator(cylinder:= Devices.bagOpenFingersSolenoidValve);
standardBagOpenFingersWithSensors(
	simulateIO:= HMIData.simulateAllIO,
	simMissedBag:= UN00_Globals.simFaults.failedToGrabBagLeftFinger,
	_optionActive=> , 
	delayToGrabSetting:= HMIData.grabBagDelay,
	delayToCheckBagPresentSetting:= HMIData.checkForBagOpenDelay, 
	delayToClearSetting:= HMIData.bagClearedFromFingersDelay,
	fingerActuators := bagOpenFingersActuator, 
	BagPresentSensorLeft:= IO.iBagOpenFingersLeftBagPresent, 
	BagPresentSensorRight:= IO.iBagOpenFingersRightBagPresent);


sealFlattenerVertAxisActuator(solenoid0=> , solenoid1=> , cylinder:= Devices.sealFlattenersVertAxisSolenoidValve);
msfHorizontalMotor();
motorizedSealFlatteners(
	_optionActive=> , 
	clearanceDwellSetting:= HMIData.bagDropClearanceDwell, 
	bagWidth:= HMIData.bagWidth, 
	horizVelo:= , 
	horizAccel:= , 
	horizDecel:= , 
	bagHoldingCurrent:= , 
	sealCurrentAddition:= , 
	homeTimeoutSetting:= , 
	maximumPosition:= , 
	miniumumPosition:= , 
	clearanceOffset:= , 
	msfHorizActualPosition=> , 
	horizontalFailedToMove=> , 
	horizontalFailedToHome=> , 
	motorFault=> , 
	verticalAxis:= sealFlattenerVertAxisActuator, 
	horizontalAxis:= msfHorizontalMotor);
	
	bagDeliveryFrontMotor();
	bagDelivery(
	simulateIO := HMIData.simulateAllIO,
	_optionActive=> , 
	printer:= labelPrinter, 
	bagLength:= HMIData.bagLength, 
	feedSpeed:= TO_REAL(HMIData.bagForwardSpeed), 
	reverseSpeed:= TO_REAL(HMIData.bagReverseSpeed), 
	printSpeed:= , 
	printOffset:= , 
	printLength:= , 
	maxReverseSetpoint:= , 
	sealOffset:= , 
	distanceFromSealBarToBagEdge:= , 
	distanceFromNipToBagEdge:= , 
	bagPhotoeyeInput:= IO.iBagPhotoeyeClear, 
	trapezoidalPercent:= , 
	bagDeliveryFailedToMove=> , 
	bagFailedToSeparate=> , 
	bagDeliveryMotor:= bagDeliveryFrontMotor);