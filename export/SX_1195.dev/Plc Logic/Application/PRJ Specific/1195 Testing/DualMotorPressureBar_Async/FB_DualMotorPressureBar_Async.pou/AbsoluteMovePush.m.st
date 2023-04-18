(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD AbsoluteMovePush
VAR_INPUT
	motionProfile : sctMotionProfile;
	nextState : eDualMotorPressureBar_AsyncStates;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Front Motor
MC_MoveFrontMotorPush.position := motionProfile.position;
MC_MoveFrontMotorPush.velocity := motionProfile.velocity;
MC_MoveFrontMotorPush.acceleration := motionProfile.acceleration; 
MC_MoveFrontMotorPush.deceleration := motionProfile.deceleration;
MC_MoveFrontMotorPush.currentLimit := motionProfile.current;
MC_MoveFrontMotorPush.execute := TRUE;

// Start Timeout Timer
_timeoutTimer.IN := TRUE;
//_timeoutTimer.PT := MoveTimeoutCalc(ABS(frontMotor.actualPositonInInches - position), velocity, 1000);

// Update State
state := nextState;