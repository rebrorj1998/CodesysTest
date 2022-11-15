(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AppliedMotionStepServoEIPPassthrough EXTENDS FB_AppliedMotionStepServoEIPBase
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
	homingState : JAW_HOMING_STATES;
	homeRequiredONS : R_TRIG;
	timerHomeDelay : TON;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();
