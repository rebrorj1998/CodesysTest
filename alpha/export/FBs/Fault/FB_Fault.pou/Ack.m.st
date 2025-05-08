(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Ack(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF _ack OR _acked THEN
	RETURN;
END_IF
_acked := TRUE;
// Log the ACK.
_logger.AddLogItem(CONCAT(InstanceName,  ' Acked'));