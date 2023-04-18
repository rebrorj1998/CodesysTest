(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD AbsoluteMove
VAR_INPUT
	motionProfile : sctMotionProfile;
	nextState : eDualMotorPressureBar_AsyncStates;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Front Motor
MC_MoveFrontMotorABS.position := motionProfile.position;
MC_MoveFrontMotorABS.velocity := motionProfile.velocity;
MC_MoveFrontMotorABS.acceleration := motionProfile.acceleration; 
MC_MoveFrontMotorABS.deceleration := motionProfile.deceleration;
MC_MoveFrontMotorABS.currentLimit := motionProfile.current;
MC_MoveFrontMotorABS.execute := TRUE;

// Start Timeout Timer
_timeoutTimer.IN := TRUE;
//_timeoutTimer.PT := MoveTimeoutCalc(ABS(frontMotor.actualPositonInInches - position), velocity, 1000);

// Update State
state := nextState;