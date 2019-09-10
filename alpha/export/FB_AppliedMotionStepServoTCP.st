

FUNCTION_BLOCK FB_AppliedMotionStepServoTCP EXTENDS FB_AppliedMotionStepServoMBBase IMPLEMENTS IPositionableMotor
VAR_INPUT
END_VAR
VAR_IN_OUT
    slave : IoDrvModbusTCP.ModbusTCPSlave;                    //Slave ModbusTCP Object
END_VAR
VAR_OUTPUT
END_VAR
VAR
    sendMoveCommand : FB_SendMoveCommandAppliedMotionTCP();
    sendOpcodeCommand :  FB_SendOpcodeCommandAppliedMotionTCP();
END_VAR

sendMoveCommand(Slave := slave);
sendOpcodeCommand(Slave := slave);

commandSuccessful S= (sendMoveCommand.xDone OR sendOpcodeCommand.xDone) AND NOT status.inPosition;

METHOD Stop

commandSuccessful := FALSE;
SendOpcodeCommand.opcode := STEP_SERVO_OPCODES.STOP_MOVE_KILL_BUFFER;
SendOpcodeCommand.Execute();

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

//This method preps the data to send to the drive and triggers the send.
//Set distance and unpack to prep data to send to motor
distanceToMoveInSteps.rawValue := REAL_TO_DINT((position) * stepsPerInchSetpoint);
IF reversePolarity THEN
    distanceToMoveInSteps.rawValue := distanceToMoveInSteps.rawValue * -1;    
END_IF
commandSuccessful := FALSE;
ModbusLongHandler.Unpack(distanceToMoveInSteps);
sendMoveCommand.acceleration := acceleration;
sendMoveCommand.deceleration := deceleration;
sendMoveCommand.velocity := velocity;
sendMoveCommand.distanceHighWord := distanceToMoveInSteps.highWord;
sendMoveCommand.distanceLowWord := distanceToMoveInSteps.lowWord;
sendMoveCommand.opcode := STEP_SERVO_OPCODES.FEED_TO_POSITION;
sendMoveCommand.Execute();

METHOD ExecuteStoredProgram
VAR_INPUT
    (*Program number to execute*)
    programNumber    : INT;
END_VAR

//Load program into queue by setting it as parameter 1 and send it and the execute queue opcode
commandSuccessful := FALSE;
SendOpcodeCommand.opcode := STEP_SERVO_OPCODES.QUEUE_LOAD_AND_EXECUTE;
SendOpcodeCommand.Parameter1 := INT_TO_WORD(programNumber);
SendOpcodeCommand.Execute();

METHOD MoveDistance
VAR_INPUT
    distance : REAL;        //Distance to move in inches
    acceleration : INT;        //Acceleration in RPM/sec
    deceleration : INT;        //Deceleration in RPM/sec
    velocity : INT;            //Velocity in .25RPM
END_VAR
//This method preps the data to send to the drive and triggers the send.
//Set distance and unpack to prep data to send to motor
distanceToMoveInSteps.rawValue := REAL_TO_DINT((distance) * stepsPerInchSetpoint);
IF reversePolarity THEN
    distanceToMoveInSteps.rawValue := distanceToMoveInSteps.rawValue * -1;    
END_IF
commandSuccessful := FALSE;
ModbusLongHandler.Unpack(distanceToMoveInSteps);
sendMoveCommand.acceleration := acceleration;
sendMoveCommand.deceleration := deceleration;
sendMoveCommand.velocity := velocity;
sendMoveCommand.distanceHighWord := distanceToMoveInSteps.highWord;
sendMoveCommand.distanceLowWord := distanceToMoveInSteps.lowWord;
sendMoveCommand.opcode := STEP_SERVO_OPCODES.FEED_TO_LENGTH;
sendMoveCommand.Execute();

METHOD HomeNow

//Load program 1 into queue by setting it as parameter 1 and send it and the execute queue opcode
ExecuteStoredProgram(QX_PROGRAMS.HOME_HARD_STOP);
HomeRequired := FALSE;