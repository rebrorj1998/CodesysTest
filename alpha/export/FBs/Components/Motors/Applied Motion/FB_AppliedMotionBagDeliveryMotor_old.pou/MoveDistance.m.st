(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD MoveDistance
VAR_INPUT
    distance : REAL;        //Distance to move in inches
    acceleration : INT;        //Acceleration in RPM/sec
    deceleration : INT;        //Deceleration in RPM/sec
    velocity : INT;            //Velocity in .25RPM
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
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