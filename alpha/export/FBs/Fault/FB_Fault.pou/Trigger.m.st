(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Trigger
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF _active = TRUE THEN
	RETURN;
END_IF
_active := TRUE;
GlobalObjects.CollectionOfActiveFaults.AddObject(THIS^);
IF _logger <> 0 THEN
	_logger.AddLogItem(CONCAT(InstanceName,  ' Active'));
END_IF
