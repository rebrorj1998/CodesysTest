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
IF _initialize OR placement = BAG_DELIVERY_MOTOR_PLACEMENT.Rear AND interconnect = BAG_DELIVERY_IC.CBL THEN
	RETURN;
END_IF

//
_moveDone := FALSE;
_moveFinal := TRUE;
_stateFinal := BAG_DELIVERY_MOVE_STATES.Idle;

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
