(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Trigger
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF NOT _active THEN
    _active := TRUE;
	GlobalObjects.CollectionOfActiveFaults.AddObject(THIS^);
	IF _logger <> 0 THEN
		_logger.AddLogItem(CONCAT(InstanceName, ' Active'));
	END_IF
END_IF
