

FUNCTION_BLOCK FB_AppliedMotionStepServoEIPBaseQX IMPLEMENTS IPositionableMotor, IStoredProgramMotor
VAR_INPUT
    ptrEIPInputs : POINTER TO ARRAY[0..13] OF  DINT;
    ptrEIPOutputs : POINTER TO ARRAY[0..15] OF DINT;
    faultHandler : REFERENCE TO FB_FaultHandler;
	commFail : BOOL;
    stepsPerInchSetpoint : INT;             //Steps per inch setpoint
    reversePolarity : BOOL;                 //0 = Normal, 1 = reversed polarity for display
    jogAccelSetpoint : INT;        //Point-to-Point Acceleration (AC) Setpoint
    jogDecelSetpoint : INT;        //Point-to-Point Deceleration (DE) Setpoint
    jogVelocitySetpoint : INT;                //Velocity (VE) Setpoint
    pointToPointAccelSetpoint : INT;        //Point-to-Point Acceleration (AC) Setpoint
    pointToPointDecelSetpoint : INT;        //Point-to-Point Deceleration (DE) Setpoint
    velocitySetpoint : INT;                //Velocity (VE) Setpoint
	defaultCurrentSetpoint : DINT;
	sclCommand : DINT;						// SCL Command from 
	parameter1 : DINT;						// Data/SCL parameter 1
	parameter2 : DINT;						// Data/SCL parameter 2
    distanceSetpointInches : REAL;        //Distance setpoint in inches Setpoint
    moveDistanceManualPB : BOOL;            //Move distance pushbutton
    movePositionManualPB : BOOL;            //Move position pushbutton
	isHomable : BOOL;
END_VAR
VAR_IN_OUT
    //slave : IoDrvModbusTCP.ModbusTCPSlave;                    //Slave ModbusTCP Object
END_VAR
VAR
    absolutePositionSteps : DINT; //Immediate Absolute Position in steps
    distanceToMoveInSteps : DINT;        //Distance Setpoint to Drive
    stepServoStatusRaw : INT; //Raw step servo status over modbus
	stepServoAlarmCodeRaw : INT; // Ras Step Servo alarm code word
	currentLimit : DINT;
    commands : FB_StepServoCommands();
    commandSuccessful : BOOL;    //Modbus Command was successful
    commandSuccessfulONS : R_TRIG;    //Modbus Command was successful
    commandSentONS : R_TRIG;    //Modbus Command was successful
    homeRequiredIndication : BOOL; //Home required indication.
    driveInputs : ARRAY[0..13] OF DINT;        // Inputs from drive over EIP
    driveOutputs : ARRAY[0..15] OF DINT;    // Outputs to drive over EIP
    interfaceToPass : IFault;
    faultListRegisterSuccess : BOOL;        // Registering in fault list successful
    _faulted : BOOL;                    // Motor Faulted
	_reset : BOOL;			//Reset Motor
	_homeNow : BOOL;
	homingOSF : F_TRIG;
	
	IECReferenceGood : BOOL;
END_VAR
VAR_OUTPUT
    absolutePositonInches : REAL; //Immediate Absolute Positon in inches
    velocity : INT;    //Velocity (VE) Input from Drive
    status : StepServoStatusFB; //Status of servo
	alarms : FB_StepServoAlarms; // Alarms from Drive
    QSegmentRunning : INT; //Current Q program running from Drive
	faults : StepServoFaultsType;
END_VAR


IF NOT faultListRegisterSuccess THEN
    faultListRegisterSuccess := RegisterWithFaultHandler();
END_IF

METHOD Execute
VAR_INPUT
END_VAR

//    Function Block: AppliedMotionStepServo
//    Description: This block provides an abstraction for a Ethernet I/P Applied Motion Step Servo
//    Created by: Ben Hess
//    Created Date: May 11th, 2018

// Use pointers for EIP memory register locations
driveInputs := ptrEIPInputs^;

ptrEIPOutputs^ := driveOutputs;
alarms(alarmCode := stepServoAlarmCodeRaw, faults := faults);

IF currentLimit = 0 THEN 
	currentLimit := defaultCurrentSetpoint;
END_IF
//Map raw EIP Registers to parameters
absolutePositionSteps := driveInputs[6];
velocity := DINT_TO_INT(driveInputs[8]);
stepServoStatusRaw := DINT_TO_INT(driveInputs[0]);

driveOutputs[4] := velocitySetpoint;
driveOutputs[5] := pointToPointAccelSetpoint;
driveOutputs[6] := pointToPointDecelSetpoint;
driveOutputs[7] := distanceToMoveInSteps;
driveOutputs[8] := currentLimit;
driveOutputs[9] := sclCommand;
driveOutputs[10] := parameter1;
driveOutputs[11] := parameter2;
driveOutputs[12] := currentLimit;
driveOutputs[13] := currentLimit + 1;
driveOutputs[0] := commands.commandWord;
// Step servo command bits handler
commands();
//Convert Distance setpoint to steps.  Reverse polarity for display purposes if needed. 

absolutePositonInches := (DINT_TO_REAL(absolutePositionSteps) / INT_TO_REAL(stepsPerInchSetpoint));

//Homing required from motor - for now just if there was an initialization seen.
homeRequiredIndication S= status.initializing OR Globals.firstScan OR _faulted OR driveInputs[11].0;

homingOSF(CLK := status.homing);
IF NOT driveInputs[11].0 THEN
	homeRequiredIndication := FALSE;
END_IF

commandSentONS(CLK := commands.commandSent);

IF commandSentONS.Q THEN
	commandSuccessful := TRUE;
END_IF

commandSuccessfulONS(CLK := commandSuccessful);
IF commandSuccessfulONS.Q THEN
	//parameter1 := 0;
	//velocitySetpoint := 0;
	//pointToPointAccelSetpoint := 0;
	//pointToPointDecelSetpoint := 0;
	//distanceToMoveInSteps := 0;
END_IF


IF _reset AND (status.driveFaulted OR status.alarmPresent) THEN
	commands.alarmReset := TRUE;
	_reset := FALSE;
END_IF

IF reversePolarity THEN
    absolutePositonInches := absolutePositonInches * -1; 
END_IF

//Get Servo Status and unpack
status(statusCode := StepServoStatusRaw);

//Bit-packing for LONG types over Modbus

_faulted := status.driveFaulted OR status.alarmPresent OR commFail;

//Manual moves for motor
IF moveDistanceManualPB THEN
    MoveDistance(distance := distanceSetpointInches, acceleration := pointToPointAccelSetpoint, deceleration := pointToPointDecelSetpoint, velocity := velocitySetpoint);
    moveDistanceManualPB := FALSE;
END_IF

IF movePositionManualPB THEN
    MoveToPosition(position := distanceSetpointInches, acceleration := pointToPointAccelSetpoint, deceleration := pointToPointDecelSetpoint, velocity := velocitySetpoint);
    movePositionManualPB := FALSE;
END_IF


faults.commFail.faultTrigger := commFail AND Globals.machinePowerOK;
faults.notHomed.faultTrigger := homeRequiredIndication AND isHomable;



{attribute 'monitoring' := 'variable'}
PROPERTY CommandAcknowledged : BOOL


METHOD HomeNow
commandSuccessful := FALSE;
parameter1 := 1;
pointToPointAccelSetpoint := 1000;
pointToPointDecelSetpoint := 1000;
velocitySetpoint := 2500;
distanceToMoveInSteps := 0;
commands.sendQAndExecute := TRUE;

//homeRequiredIndication := FALSE;

{attribute 'monitoring' := 'variable'}
PROPERTY Homing : BOOL


{attribute 'monitoring' := 'variable'}
PROPERTY HomeRequired : BOOL


{attribute 'monitoring' := 'variable'}
PROPERTY Moving : BOOL


{attribute 'monitoring' := 'variable'}
PROPERTY ActiveStoredProgramNumber : INT


{attribute 'monitoring' := 'variable'}
PROPERTY InPosition : BOOL


METHOD MoveDistanceTorque
VAR_INPUT
	(*Distance to move in inches*)
    distance    : REAL;
    (*Acceleration in RPM/sec*)
    acceleration    : INT;
    (*Deceleration in RPM/sec*)
    deceleration    : INT;
    (*Velocity in .25RPM*)
    velocity    : INT;
	(*Current in .01A*)
	current : DINT;
END_VAR

//This method preps the data to send to the drive and triggers the send.
//Set distance and unpack to prep data to send to motor

commandSuccessful := FALSE;

distanceToMoveInSteps := REAL_TO_DINT((distance) * stepsPerInchSetpoint);
IF reversePolarity THEN
    distanceToMoveInSteps := distanceToMoveInSteps * -1;
END_IF

pointToPointAccelSetpoint := acceleration;
pointToPointDecelSetpoint := deceleration;
velocitySetpoint := velocity;
currentLimit := current;

parameter1 := 2;
commands.SendQAndExecute := TRUE;

(* This will be called if the machine is faulted*)
METHOD MachineFaulted



{attribute 'monitoring' := 'variable'}
PROPERTY Faulted : BOOL


METHOD MoveToPosition
VAR_INPUT
    (*Position to move to in inches*)
    position    : REAL;
    (*Acceleration in RPM/sec*)
    acceleration    : INT;
    (*Deceleration in RPM/sec*)
    deceleration    : INT;
    (*Velocity in .25RPM*)
    velocity    : INT;
END_VAR

commandSuccessful := FALSE;

distanceToMoveInSteps := REAL_TO_DINT((position) * stepsPerInchSetpoint);
IF reversePolarity THEN
    distanceToMoveInSteps := distanceToMoveInSteps * -1;    
END_IF

pointToPointAccelSetpoint := acceleration;
pointToPointDecelSetpoint := deceleration;
velocitySetpoint := velocity;
currentLimit := defaultCurrentSetpoint;

commands.feedToPosition := TRUE;

METHOD MoveToPositionTorque
VAR_INPUT
	(*Position to move to in inches*)
    position    : REAL;
    (*Acceleration in RPM/sec*)
    acceleration    : INT;
    (*Deceleration in RPM/sec*)
    deceleration    : INT;
    (*Velocity in .25RPM*)
    velocity    : INT;
	(*Current in .01A*)
	current : DINT;
END_VAR

commandSuccessful := FALSE;

distanceToMoveInSteps := REAL_TO_DINT((position) * stepsPerInchSetpoint);
IF reversePolarity THEN
    distanceToMoveInSteps := distanceToMoveInSteps * -1;    
END_IF

pointToPointAccelSetpoint := acceleration;
pointToPointDecelSetpoint := deceleration;
velocitySetpoint := velocity;
currentLimit := current;

commands.feedToPosition := TRUE;
THIS^.Execute();

//{warning 'add method implementation '}
METHOD Stop

commandSuccessful := FALSE;
commands.StopNormal := TRUE;

METHOD MoveDistance
VAR_INPUT
    (*Distance to move in inches*)
    distance    : REAL;
    (*Acceleration in RPM/sec*)
    acceleration    : INT;
    (*Deceleration in RPM/sec*)
    deceleration    : INT;
    (*Velocity in .25RPM*)
    velocity    : INT;
END_VAR

//This method preps the data to send to the drive and triggers the send.
//Set distance and unpack to prep data to send to motor

commandSuccessful := FALSE;

distanceToMoveInSteps := REAL_TO_DINT((distance) * stepsPerInchSetpoint);
IF reversePolarity THEN
    distanceToMoveInSteps := distanceToMoveInSteps * -1;
END_IF

pointToPointAccelSetpoint := acceleration;
pointToPointDecelSetpoint := deceleration;
velocitySetpoint := velocity;
currentLimit := defaultCurrentSetpoint;

commands.feedToLength := TRUE;

{attribute 'monitoring' := 'variable'}
PROPERTY CurrentPosition : REAL  //Current motor position in Inches

METHOD Reset : BOOL
VAR_INPUT
END_VAR

IF Faulted THEN
	_reset := TRUE;
	commands.AlarmReset := TRUE;
END_IF
commands.Enable := TRUE;

METHOD RegisterWithFaultHandler : BOOL

// If faulthandler hasn't been initialized yet then do nothing.

(*
IF NOT __ISVALIDREF(faultHandler) THEN
     RETURN;
END_IF

interfaceToPass := THIS^;
faultHandler.registerFaultSource(interfaceToPass);
RegisterWithFaultHandler := TRUE;
*)


METHOD ExecuteStoredProgram
VAR_INPUT
    (*Program number to execute*)
    programNumber    : INT;
END_VAR

parameter1 := programNumber;
commands.SendQAndExecute := TRUE;