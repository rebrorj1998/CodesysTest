(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD MoveDistance
VAR_INPUT
    (*Distance to move in inches*)
    distance    : REAL;
    (*Acceleration in RPM/sec*)
    acceleration    : INT;
    (*Deceleration in RPM/sec*)
    deceleration    : INT;
    (*Velocity in .25RPM*)
    velocity    : INT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//This method preps the data to send to the drive and triggers the send.
//Set distance and unpack to prep data to send to motor

commandSuccessful := FALSE;

distanceToMoveInSteps := REAL_TO_DINT((distance) * stepsPerInchSetpoint);
IF reversePolarity THEN
    distanceToMoveInSteps := distanceToMoveInSteps * -1;
END_IF

pointToPointAccelSetpoint := acceleration;
pointToPointDecelSetpoint := deceleration;
velocitySetpoint := velocity;
currentLimit := defaultCurrentSetpoint;
IF driveInputs[5] <> driveInputs[6] THEN
	ResetEncoderPosition(driveinputs[5]);
ELSE
	commands.feedToLength := TRUE;
END_IF
