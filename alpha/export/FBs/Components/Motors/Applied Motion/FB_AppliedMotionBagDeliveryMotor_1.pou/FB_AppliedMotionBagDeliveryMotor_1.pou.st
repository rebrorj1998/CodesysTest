(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AppliedMotionBagDeliveryMotor_1 EXTENDS FB_AppliedMotionStepServoEIPBase
VAR_INPUT
	rearMotor : BOOL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_moveDistance : BOOL;
	_moveDistanceONS : R_TRIG;
	_moveFinal : BOOL;
	_moveFinalONS : R_TRIG;
	_moveDone : BOOL;
	waitForMove : TON := (PT := T#30MS);
	manualFinalMovePB : BOOL;
	movedFinal : BOOL;
	moveDistanceState : AMP_EIP_MOVE_INITIAL_STATES;
	moveDistanceFinalState : AMP_EIP_MOVE_INITIAL_STATES;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
