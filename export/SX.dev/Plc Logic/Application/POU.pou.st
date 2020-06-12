(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PROGRAM POU
VAR
	testASCII : FB_PrinterSerial;
	serial : FB_CrevisSerial();
	fastBagDelivery : FB_SXBagDelivery(name := 'Bag Delivery') := (_optionEnabled := TRUE, _optionInstalled := TRUE);
	//bagDeliveryFrontMotor : FB_AppliedMotionMotorMB;
	//bagDeliveryFrontMotor : FB_SimMotor;
	fastBagDeliveryFrontMotor : FB_AppliedMotionMotorASCII;
	powerUpBagDeliveryMotor : Sharp_Motion.MC_Power();
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
testASCII();

powerUpBagDeliveryMotor(Enable := TRUE, Axis := fastBagDeliveryFrontMotor);
powerUpBagDeliveryMotor.DriveStart := TRUE;
powerUpBagDeliveryMotor.RegulatorOn := TRUE;

serial(
	xExecute:= , 
	xDone=> , 
	xBusy=> , 
	xError=> , 
	sendData:= , 
	receivedData=> , 
	inputs:= ADR(serialInputs), 
	outputs:= ADR(serialOutputs));
	
	fastBagDeliveryFrontMotor(
	AxisState:= , 
	SetOpMode:= , 
	PowerOn:= , 
	DriveEnable:= , 
	AckError:= , 
	StartHoming:= , 
	Halt:= , 
	NewSetPoint:= , 
	MoveAbs:= , 
	MoveAbsTorque:= , 
	MoveRel:= , 
	MoveVelo:= , 
	TargetPosDist:= , 
	TargetVelocity:= , 
	ProfileVelocity:= , 
	ProfileAcceleration:= , 
	ProfileDeceleration:= , 
	ProfileCurrentLimit:= , 
	QuickStopDeceleration:= , 
	DefaultCurrent:= , 
	ActOpMode=> , 
	CommStatus=> , 
	PowerState=> , 
	EnableState=> , 
	Error=> , 
	ActPos=> , 
	ActVelocity=> , 
	SetPointAck=> , 
	TargetReached=> , 
	InVelocity=> , 
	HomingDone=> , 
	modbusAddress:= , 
	stepsPerInchSP:= Globals.STEPS_PER_INCH_FILM, 
	zeroOffset:= , 
	jogForwardCMD:= HMIData.jogFilmForward, 
	jogReverseCMD:= HMIData.jogFilmReverse, 
	asciiHandler:= POU.serial);

	
fastBagDelivery(
	simulateIO := HMIData.simulateAllIO,
	_optionActive=> , 
	printer:= PLC_PRG.baggerCM.labelPrinter, 
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
	bagPresent:= iBagEdgePhotoeye, 
	trapezoidalPercent:= , 
	reverseFault=> , 
	bagFailedToSeparate=> , 
	bagDeliveryMotor:= fastBagDeliveryFrontMotor);