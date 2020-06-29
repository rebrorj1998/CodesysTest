(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AppliedMotionStepServoEIPBase IMPLEMENTS IPositionableMotor
VAR_INPUT
    ptrEIPInputs : POINTER TO ARRAY[0..13] OF  DINT;
    ptrEIPOutputs : POINTER TO ARRAY[0..15] OF DINT;
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
	resetState : INT;
	IECReferenceGood : BOOL;
	resetTimeout : Standard.TON;
END_VAR
VAR_OUTPUT
    absolutePositonInches : REAL; //Immediate Absolute Positon in inches
    velocity : INT;    //Velocity (VE) Input from Drive
    status : StepServoStatusFB; //Status of servo
	alarms : FB_StepServoAlarms; // Alarms from Drive
    QSegmentRunning : INT; //Current Q program running from Drive
	faults : StepServoFaultsType;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
