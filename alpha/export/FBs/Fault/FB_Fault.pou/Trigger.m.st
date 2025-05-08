(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Trigger
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF active = TRUE THEN
	RETURN;
END_IF
active := TRUE;
GlobalObjects.CollectionOfActiveFaults.AddObject(THIS^);
IF _isOEEExempt THEN
	GlobalObjects.CollectionOfOEEExemptFaults.AddObject(THIS^);
END_IF
IF _isPassiveExempt THEN
	GlobalObjects.CollectionOfPassiveExemptFaults.AddObject(THIS^);
END_IF
IF _logger <> 0 THEN
	_logger.AddLogItem(CONCAT(InstanceName,  ' Active'));
END_IF
