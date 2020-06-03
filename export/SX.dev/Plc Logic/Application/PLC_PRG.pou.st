(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PROGRAM PLC_PRG
VAR
	_deviceChecker 		: DeviceChecker;
	_deviceController	: DeviceController;		// Care: Set xAckError if an Error occurred during reconfigure.6
	_xExecute			: BOOL;					// rising edge starts the ExemplaryCase
	_xDone				: BOOL;					// Gets TRUE after an ExemplaryCase was performed
	_xConfirm			: BOOL;					// rising edge resets _xDone, eError and _xExecute.
	_eError				: DED.ERROR;			// Error returned from the device controller.
	
	powerUpTestMotor : Sharp_Motion.MC_Power;
	testMotor : FB_OrientalAZMotor;
	commPortInit : BOOL;
	moveNewPos : Sharp_Motion.MC_MoveAbsolute;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
_deviceChecker();
_deviceController();

IF _xExecute THEN
	_xExecute := FALSE;
	OutputCard0.Enable := FALSE;
	_xConfirm := DED.CanReconfigure(CVS_G_Series_Rack_);
END_IF

IF HMI.data.bagLength > 30 THEN
	HMI.data.bagLength := 30;
END_IF
oSealWire := iBagEdgePhotoeye;
IF NOT Globals.modbusRTUCom.xInit THEN
	Globals.modbusRTUCom.hComPort := SysCom.SysComOpen2(pSettings := ADR(Globals.modbusRTUCom.sctSettings),0, pResult:=Globals.modbusRTUCom.pResult);
	Globals.modbusRTUCom.xInit := TRUE;
END_IF

powerUpTestMotor(Enable := TRUE, Axis := testMotor);
powerUpTestMotor.DriveStart := TRUE;
powerUpTestMotor.RegulatorOn := TRUE;

moveNewPos(
	Execute:= , 
	Done=> , 
	Busy=> , 
	CommandAborted=> , 
	Error=> , 
	ErrorID=> , 
	Axis:= testMotor, 
	Position:= , 
	Velocity:= , 
	Acceleration:= , 
	Deceleration:= );

testMotor(
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
	DefaultCurrent:= 100, 
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
	modbusAddress:= 15, 
	stepsPerInchSP := 1000,
	jogForwardCMD := HMI.data.jawJogOpen,
	jogReverseCMD := HMI.data.jawjobClosed,
	comm:= Globals.modbusRTUCom.hComPort);
