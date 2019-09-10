

FUNCTION_BLOCK FB_AppliedMotionBagDeliveryMotor EXTENDS FB_AppliedMotionStepServoTCP
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
    sendParameters : FB_SendUserRegistersAppliedMotionTCP();
    sendBagMoveCommand : FB_SendBagMoveAppliedMotionTCP();
END_VAR

sendMoveCommand(Slave := slave);
sendBagMoveCommand(Slave := slave);
sendOpcodeCommand(Slave := slave);
sendParameters(Slave := slave);

commandSuccessful S= ((sendMoveCommand.xDone OR sendOpcodeCommand.xDone OR sendBagMoveCommand.xDone) AND NOT status.inPosition) OR sendParameters.xDone;

METHOD MoveDistance
VAR_INPUT
    distance : REAL;        //Distance to move in inches
    acceleration : INT;        //Acceleration in RPM/sec
    deceleration : INT;        //Deceleration in RPM/sec
    velocity : INT;            //Velocity in .25RPM
END_VAR
distanceToMoveInSteps.rawValue := REAL_TO_DINT((distance) * stepsPerInchSetpoint);
IF reversePolarity THEN
    distanceToMoveInSteps.rawValue := distanceToMoveInSteps.rawValue * -1;    
END_IF
commandSuccessful := FALSE;
ModbusLongHandler.Unpack(distanceToMoveInSteps);
sendBagMoveCommand.acceleration := acceleration;
sendBagMoveCommand.deceleration := deceleration;
sendBagMoveCommand.velocity := velocity;
sendBagMoveCommand.distanceHighWord := distanceToMoveInSteps.highWord;
sendBagMoveCommand.distanceLowWord := distanceToMoveInSteps.lowWord;
sendBagMoveCommand.opcode := STEP_SERVO_OPCODES.QUEUE_LOAD_AND_EXECUTE;
sendBagMoveCommand.programToRun := 1;
sendBagMoveCommand.Execute();

METHOD SendParameters
VAR_INPUT
    reverseSpeed : DINT;
    
END_VAR



METHOD MoveDistanceFinal
VAR_INPUT
    distance : REAL;        //Distance to move in inches
    acceleration : INT;        //Acceleration in RPM/sec
    deceleration : INT;        //Deceleration in RPM/sec
    velocity : INT;            //Velocity in .25RPM
END_VAR

distanceToMoveInSteps.rawValue := REAL_TO_DINT((distance) * stepsPerInchSetpoint);
IF reversePolarity THEN
    distanceToMoveInSteps.rawValue := distanceToMoveInSteps.rawValue * -1;    
END_IF
commandSuccessful := FALSE;
ModbusLongHandler.Unpack(distanceToMoveInSteps);
sendBagMoveCommand.acceleration := acceleration;
sendBagMoveCommand.deceleration := deceleration;
sendBagMoveCommand.velocity := velocity;
sendBagMoveCommand.distanceHighWord := distanceToMoveInSteps.highWord;
sendBagMoveCommand.distanceLowWord := distanceToMoveInSteps.lowWord;
sendBagMoveCommand.opcode := STEP_SERVO_OPCODES.QUEUE_LOAD_AND_EXECUTE;
sendBagMoveCommand.programToRun := 2;
sendBagMoveCommand.Execute();

METHOD StopViaProgram

// Load program segment 12 into buffer and execute.  This program contains nothing but a SM command.
// We must do it this way because the normal "stop command" opcode we have access to over modbus 
// also kills the program buffer which is bad.
commandSuccessful := FALSE;
SendOpcodeCommand.opcode := STEP_SERVO_OPCODES.QUEUE_LOAD_AND_EXECUTE;
SendOpcodeCommand.Parameter1 := INT_TO_WORD(12);    //program 12 is just a SM command
SendOpcodeCommand.Execute();