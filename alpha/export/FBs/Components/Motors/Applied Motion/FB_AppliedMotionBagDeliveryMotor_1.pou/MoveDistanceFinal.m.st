(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD MoveDistanceFinal
VAR_INPUT
    distance : REAL;        //Distance to move in inches
    acceleration : INT;        //Acceleration in RPM/sec
    deceleration : INT;        //Deceleration in RPM/sec
    velocity : INT;            //Velocity in .25RPM
END_VAR

VAR
	_movefin: BOOL;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

//
_moveDone := FALSE;
_moveFinal := TRUE;
commandSuccessful := FALSE;
_moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.Idle;

//
distanceToMoveInSteps := REAL_TO_DINT((distance) * stepsPerInchSetpoint);
IF reversePolarity THEN
    distanceToMoveInSteps := distanceToMoveInSteps * -1;
END_IF

//
pointToPointAccelSetpoint := acceleration;
pointToPointDecelSetpoint := deceleration;
currentLimit := defaultCurrentSetpoint;
velocitySetpoint := velocity;
