(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AppliedMotionBagDeliveryMotor_1 EXTENDS FB_AppliedMotionStepServoEIPBase
VAR_INPUT
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
	moveDistanceState : BAG_DELIVERY_MOVE_STATES;
	moveDistanceFinalState : BAG_DELIVERY_MOVE_STATES;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
