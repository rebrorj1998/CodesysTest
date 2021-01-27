(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Execute
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
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