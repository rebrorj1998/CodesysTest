(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF _interconnect = BAG_DELIVERY_IC.EIP THEN
	InPosition := bagFeedMasterMotor.InPosition AND bagFeedRearMotor.InPosition;
ELSE
	InPosition := bagFeedMasterMotor.InPosition;
END_IF