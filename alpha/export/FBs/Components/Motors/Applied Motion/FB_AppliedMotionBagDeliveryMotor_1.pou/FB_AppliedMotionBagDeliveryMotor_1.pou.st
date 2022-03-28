(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AppliedMotionBagDeliveryMotor_1 EXTENDS FB_AppliedMotionStepServoEIPBase
VAR_INPUT
	ack : BOOL;
	position : BAG_DELIVERY_MOTOR_POSITION;
END_VAR
VAR_OUTPUT
	ackRequest : BOOL;
	tensionFault : BOOL;
END_VAR
VAR
	_moveDistance : BOOL;
	_moveFinal : BOOL;
	_moveDone : BOOL;
	_delayTimer : TON := (PT := T#10MS);
	_moveDistanceState : AMP_EIP_MOVE_INITIAL_STATES;
	_moveDistanceFinalState : AMP_EIP_MOVE_INITIAL_STATES;
	_tensionFaultDwellTimer : TON;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
