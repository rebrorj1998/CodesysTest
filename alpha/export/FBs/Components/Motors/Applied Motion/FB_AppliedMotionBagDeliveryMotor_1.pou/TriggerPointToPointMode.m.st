(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD TriggerPointToPointMode
VAR_INPUT
END_VAR

(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF interconnect = BAG_DELIVERY_IC.EIP THEN
	parameter1 := POINT2POINT_MODE_PARAM_ID;
	commands.SendQAndExecute := TRUE;	
END_IF
