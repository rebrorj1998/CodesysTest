(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD TriggerPointToPointMode
VAR_INPUT
END_VAR
VAR CONSTANT
	POINT_TO_POINT_MODE_ID : INT := 3;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
parameter1 := POINT_TO_POINT_MODE_ID;
commands.SendQAndExecute := TRUE;													
