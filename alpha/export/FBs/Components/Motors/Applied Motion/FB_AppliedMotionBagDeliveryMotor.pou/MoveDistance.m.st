(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD MoveDistance
VAR_INPUT
    distance : REAL;    // Distance to move in inches
    acceleration : INT; // Acceleration in RPM/sec
    deceleration : INT; // Deceleration in RPM/sec
    velocity : INT;     // Velocity in .25RPM
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

//
IF RearMotor AND NOT EIP THEN
	RETURN;
END_IF

//
_moveDone := FALSE;
_moveFinal := FALSE;
_moveDistance := TRUE;
_state := BAG_DELIVERY_MOVE_STATES.Idle;

//
distanceToMoveInSteps := REAL_TO_DINT((distance) * stepsPerInchSetpoint);
IF reversePolarity THEN
    distanceToMoveInSteps := distanceToMoveInSteps * -1;
END_IF

//
commandSuccessful := FALSE;
pointToPointAccelSetpoint := acceleration;
pointToPointDecelSetpoint := deceleration;
currentLimit := defaultCurrentSetpoint;
velocitySetpoint := velocity;

