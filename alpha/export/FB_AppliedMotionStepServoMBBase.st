

FUNCTION_BLOCK FB_AppliedMotionStepServoMBBase IMPLEMENTS IPositionableMotor, IStoredProgramMotor
VAR_INPUT
    modbusInputParameters : ARRAY[0 .. 124] OF WORD;        //This is the input array of words of raw Modbus registers
    stepsPerInchSetpoint : INT;                                        //Steps per inch setpoint
    reversePolarity : BOOL;                                    //0 = Normal, 1 = reversed polarity for display
    pointToPointAccelSetpoint : INT;        //Point-to-Point Acceleration (AC) Setpoint
    pointToPointDecelSetpoint : INT;        //Point-to-Point Deceleration (DE) Setpoint
    velocitySetpoint : INT;                //Velocity (VE) Setpoint
    distanceSetpointInches : REAL;        //Distance setpoint in inches Setpoint
    moveDistanceManualPB : BOOL;            //Move distance pushbutton
    movePositionManualPB : BOOL;            //Move position pushbutton
END_VAR
VAR_IN_OUT
    //slave : IoDrvModbusTCP.ModbusTCPSlave;                    //Slave ModbusTCP Object
END_VAR
VAR
    ModbusLongHandler : ModbusLongHandlerFB();
    absolutePositionSteps : ModbusLongType; //Immediate Absolute Position in steps
    distanceSteps : ModbusLongType;    //Point-to-Point Distance (DI) Input from Drive Combined
    distanceToMoveInSteps : ModbusLongType;        //Distance Setpoint to Drive
    stepServoStatusRaw : INT; //Raw step servo status over modbus
    commandSuccessful : BOOL;    //Modbus Command was successful
    homeRequiredIndication : BOOL; //Home required indication.
    //commandAcked : BOOL;        //Command acked from "send" function blocks
    interfaceToPass : IFault;
    faultListRegisterSuccess : BOOL;        // Registering in fault list successful
    _faulted : BOOL;                    // Motor Faulted
END_VAR
VAR_OUTPUT
    absolutePositonInches : REAL; //Immediate Absolute Positon in inches
    distanceInches : REAL;            //Distance from Drive converted to inches
    homeAccel : INT;    //Home Acceleration (HA) Input from Drive
    homeCurrentLimit : INT;    //Home Hard Stop current limit (HC) Input from Drive
    homeDecel : INT;    //Home Deceleration (HL) Input from Drive
    homeVelocity : INT;    //Home Speed (HV) from Drive
    jogAccel : INT;    //Jog Acceleration (AC) Input from Drive
    jogDecel : INT;    //Jog Deceleration (DE) Input from Drive
    jogVelocity : INT;    //Jog Speed from Drive
    pointToPointAccel : INT;    //Point-to-Point Acceleration (AC) Input from Drive
    pointToPointDecel : INT;    //Point-to-Point Deceleration (DE) Input from Drive
    velocity : INT;    //Velocity (VE) Input from Drive
    status : StepServoStatusFB; //Status of servo
    QSegmentRunning : INT; //Current Q program running from Drive
END_VAR



METHOD Execute
VAR_INPUT
END_VAR

//    Function Block: AppliedMotionStepServo
//    Description: This block provides an abstraction for a Applied Motion Step Servo
//    Created by: Ben Hess
//    Created Date: April 2nd, 2018

//Map raw Modbus Registers to parameters
absolutePositionSteps.highWord := modbusInputParameters[6];
absolutePositionSteps.lowWord := modbusInputParameters[7];
distanceSteps.highWord := modbusInputParameters[30];
distanceSteps.lowWord := modbusInputParameters[31];
jogAccel := WORD_TO_INT(modbusInputParameters[46]);
jogDecel := WORD_TO_INT(modbusInputParameters[47]);
jogVelocity := WORD_TO_INT(modbusInputParameters[48]);
pointToPointAccel := WORD_TO_INT(modbusInputParameters[27]);
pointToPointDecel := WORD_TO_INT(modbusInputParameters[28]);
velocity := WORD_TO_INT(modbusInputParameters[29]);
stepServoStatusRaw := WORD_TO_INT(modbusInputParameters[1]);
QSegmentRunning := WORD_TO_INT(modbusInputParameters[17]);

//Convert Distance setpoint to steps.  Reverse polarity for display purposes if needed. 
//oDistanceSteps.displayValue := REAL_TO_DINT((oDistanceInches) * stepsPerInch);
//oDistanceSteps.rawValue := REAL_TO_DINT((oDistanceInches ) * stepsPerInch);
//DistanceSteps.displayValue := DistanceSteps.rawValue;
distanceInches := (DINT_TO_REAL(distanceSteps.displayValue) / INT_TO_REAL(stepsPerInchSetpoint));    
absolutePositionSteps.displayValue := absolutePositionSteps.rawValue;
absolutePositonInches := (DINT_TO_REAL(absolutePositionSteps.displayValue) / INT_TO_REAL(stepsPerInchSetpoint));

//Homing required from motor - for now just if there was an initialization seen.
homeRequiredIndication S= status.initializing OR Globals.firstScan;

IF reversePolarity THEN
    //oDistanceSteps.rawValue := oDistanceSteps.rawValue * -1; 
    distanceInches := distanceInches * -1;
    absolutePositonInches := absolutePositonInches * -1; 
END_IF

//Get Servo Status and unpack
status(statusCode := StepServoStatusRaw);

//Bit-packing for LONG types over Modbus
ModbusLongHandler.Pack(distanceSteps);
ModbusLongHandler.Pack(absolutePositionSteps);


//Manual moves for motor
IF moveDistanceManualPB THEN
    MoveDistance(distance := distanceSetpointInches, acceleration := pointToPointAccelSetpoint, deceleration := pointToPointDecelSetpoint, velocity := velocitySetpoint);
    moveDistanceManualPB := FALSE;
END_IF

IF movePositionManualPB THEN
    MoveToPosition(position := distanceSetpointInches, acceleration := pointToPointAccelSetpoint, deceleration := pointToPointDecelSetpoint, velocity := velocitySetpoint);
    movePositionManualPB := FALSE;
END_IF

{attribute 'monitoring' := 'variable'}
PROPERTY HomeRequired : BOOL


{attribute 'monitoring' := 'variable'}
PROPERTY CommandAcknowledged : BOOL


METHOD ExecuteStoredProgram
VAR_INPUT
    (*Program number to execute*)
    programNumber    : INT;
END_VAR



{attribute 'monitoring' := 'variable'}
PROPERTY Homing : BOOL


{attribute 'monitoring' := 'variable'}
PROPERTY ActiveStoredProgramNumber : INT


{attribute 'monitoring' := 'variable'}
PROPERTY Moving : BOOL


//{warning 'add method implementation '}
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



{attribute 'monitoring' := 'variable'}
PROPERTY InPosition : BOOL


METHOD HomeNow



//{warning 'add method implementation '}
METHOD Stop



{attribute 'monitoring' := 'variable'}
PROPERTY CurrentPosition : REAL  //Current motor position in Inches

//{warning 'add method implementation '}
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

