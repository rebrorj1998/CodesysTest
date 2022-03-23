(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AppliedMotionBagDeliveryMotor_1 EXTENDS FB_AppliedMotionStepServoEIPBase
VAR_INPUT
	ack : BOOL;
END_VAR
VAR_OUTPUT
	ackRequest : BOOL;
END_VAR
VAR
	_point2pointModeTestBit : BOOL;
	_tensionModeTestBit : BOOL;
	_moveDistance : BOOL;
	_moveDistanceONS : R_TRIG;
	_moveFinal : BOOL;
	_moveFinalONS : R_TRIG;
	_moveDone : BOOL;
	_waitForMove : TON;
	manualFinalMovePB : BOOL;
	_moveDistanceState : AMP_EIP_MOVE_INITIAL_STATES;
	_moveDistanceFinalState : AMP_EIP_MOVE_INITIAL_STATES;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
