(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
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
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
