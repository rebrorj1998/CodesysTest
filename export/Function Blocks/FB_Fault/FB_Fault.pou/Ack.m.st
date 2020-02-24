(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Ack(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF _ackCommand OR _acked THEN
	RETURN;
END_IF
_acked := TRUE;
// Log the ACK.
_logger.AddLogItem(CONCAT(InstanceName,  ' Acked'));
