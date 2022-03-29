(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AppliedMotionBagDeliveryMotor_1 EXTENDS FB_AppliedMotionStepServoEIPBase
VAR_INPUT
	ack : BOOL;
	placement : BAG_DELIVERY_PLACEMENT;
	interconnectivity : BAG_DELIVERY_INTERCONNECTIVITY;
END_VAR
VAR_OUTPUT
	ackRequest : BOOL;
	tensionFault : BOOL;
END_VAR
VAR
	_moveDistance : BOOL;
	_moveFinal : BOOL;
	_moveDone : BOOL;
	_initialize : BOOL;
	_delayTimer : TON := (PT := T#10MS);
	_state : BAG_DELIVERY_MOVE_STATES;
	_stateFinal : BAG_DELIVERY_MOVE_STATES;
	_stateInitalize : BAG_DELIVERY_INITALIZATION_STATES;
	_tensionFaultDwellTimer : TON := (PT := T#2S);
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
