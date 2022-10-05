(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Trigger
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF NOT _active THEN
    _active := TRUE;
	_logger.AddLogItem(CONCAT(InstanceName, ' Active'));
	GlobalObjects.CollectionOfActiveFaults.AddObject(THIS^);
END_IF
