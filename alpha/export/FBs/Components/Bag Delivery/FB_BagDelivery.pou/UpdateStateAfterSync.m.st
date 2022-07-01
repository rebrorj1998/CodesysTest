(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE UpdateStateAfterSync
VAR_INPUT
	stt : BAG_DELIVERY_STATES;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//
IF _bagFeedRearMotor.EIP THEN
	stt := BAG_DELIVERY_STATES.Sync;
	_nextState := stt;
ELSE
	state := stt;
END_IF