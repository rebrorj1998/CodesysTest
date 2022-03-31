(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF _interconnect = BAG_DELIVERY_IC.EIP THEN
	CommandAcknowledged := _bagFeedFrontMotor.CommandAcknowledged AND _bagFeedRearMotor.CommandAcknowledged;
ELSE
	CommandAcknowledged := _bagFeedFrontMotor.CommandAcknowledged;
END_IF