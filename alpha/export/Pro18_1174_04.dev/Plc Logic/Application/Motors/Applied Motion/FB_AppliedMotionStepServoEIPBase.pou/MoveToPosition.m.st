(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
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
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
commandSuccessful := FALSE;

distanceToMoveInSteps := REAL_TO_DINT((position) * stepsPerInchSetpoint);
IF reversePolarity THEN
    distanceToMoveInSteps := distanceToMoveInSteps * -1;    
END_IF

pointToPointAccelSetpoint := acceleration;
pointToPointDecelSetpoint := deceleration;
velocitySetpoint := velocity;
currentLimit := defaultCurrentSetpoint;

commands.feedToPosition := TRUE;