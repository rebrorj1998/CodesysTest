(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD MoveDistance
VAR_INPUT
    distance : REAL;        //Distance to move in inches
    acceleration : INT;        //Acceleration in RPM/sec
    deceleration : INT;        //Deceleration in RPM/sec
    velocity : INT;            //Velocity in .25RPM
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
commandSuccessful := FALSE;
_moveDone := FALSE;
moveDistanceState := BAG_DELIVERY_MOVE_STATES.Idle;
distanceToMoveInSteps := REAL_TO_DINT((distance) * stepsPerInchSetpoint);

IF reversePolarity THEN
    distanceToMoveInSteps := distanceToMoveInSteps * -1;
END_IF

pointToPointAccelSetpoint := acceleration;
pointToPointDecelSetpoint := deceleration;
velocitySetpoint := velocity;

currentLimit := defaultCurrentSetpoint;
_moveDistance := TRUE;

//commands.feedToLength := TRUE;
//SUPER^.ExecuteStoredProgram(1);