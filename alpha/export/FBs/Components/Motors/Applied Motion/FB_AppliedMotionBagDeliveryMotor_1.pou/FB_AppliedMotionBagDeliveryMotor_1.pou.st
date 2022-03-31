(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AppliedMotionBagDeliveryMotor_1 EXTENDS FB_AppliedMotionStepServoEIPBase
VAR_INPUT
	ack : BOOL;
	jog : BOOL;
	placement : BAG_DELIVERY_MOTOR_PLACEMENT;
	interconnect : BAG_DELIVERY_IC;
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
	_stateInitalize : BAG_DELIVERY_INIT_STATES;
	_tensionFaultDwellTimer : TON := (PT := T#2S);
END_VAR
VAR CONSTANT
	O2_L : INT := 16#4CB2;
	O2_H : INT := 16#48B2;
	SCL_SO : INT := 16#534F;
	TORQUE_MODE_PARAM_ID : INT := 2;
	POINT2POINT_MODE_PARAM_ID : INT := 3; 
	VELOCITY_THRESHOLD_FOR_TENSION_FAULT : INT := 1500;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
