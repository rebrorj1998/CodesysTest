(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF _interconnect = BAG_DELIVERY_IC.EIP THEN
	InPosition := _bagFeedFrontMotor.InPosition AND _bagFeedRearMotor.InPosition;
ELSE
	InPosition := _bagFeedFrontMotor.InPosition;
END_IF