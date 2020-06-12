(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Trigger
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF _active = TRUE THEN
	RETURN;
END_IF
_active := TRUE;
GlobalObjects.CollectionOfActiveFaults.AddObject(THIS^);
//_logger.AddLogItem(CONCAT(InstanceName,  ' Active'));