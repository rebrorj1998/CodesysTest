(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PointToPointOnFault : BOOL
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF _interconnect = BAG_DELIVERY_IC.CBL  THEN
	_bagFeedFrontMotor.TriggerPointToPointMode();
ELSE
	_bagFeedRearMotor.TriggerPointToPointMode();
END_IF