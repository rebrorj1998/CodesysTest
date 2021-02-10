(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD MoveDistance
VAR_INPUT
    distance : REAL;        //Distance to move in inches
    acceleration : INT;        //Acceleration in RPM/sec
    deceleration : INT;        //Deceleration in RPM/sec
    velocity : INT;            //Velocity in .25RPM
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
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