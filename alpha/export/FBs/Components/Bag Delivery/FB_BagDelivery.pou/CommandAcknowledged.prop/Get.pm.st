(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF _interconnect = BAG_DELIVERY_IC.EIP THEN
	CommandAcknowledged := bagFeedMasterMotor.CommandAcknowledged AND bagFeedRearMotor.CommandAcknowledged;
ELSE
	CommandAcknowledged := bagFeedMasterMotor.CommandAcknowledged;
END_IF