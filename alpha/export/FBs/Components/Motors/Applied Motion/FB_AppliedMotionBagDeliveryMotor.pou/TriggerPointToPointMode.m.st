(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD TriggerPointToPointMode
VAR_INPUT
END_VAR

(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
commandSuccessful := FALSE;
IF EIP THEN
	sclCommand := 0; 
	parameter1 := POINT2POINT_MODE_PARAM_ID;
	commands.SendQAndExecute := TRUE;
	_torqueMode := FALSE;	
ELSE
	sclCommand := SCL_SO; 
	parameter1 := O2_H;
	commands.SendHostCommand := TRUE;
END_IF
