(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD TriggerTorqueMode
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
commandSuccessful := FALSE;
IF EIP THEN
	sclCommand := 0;
	parameter1 := TORQUE_MODE_PARAM_ID;
	commands.SendQAndExecute := TRUE;
	_torqueMode := TRUE;
ELSE
	sclCommand := SCL_SO; 
	parameter1 := O2_L;
	commands.SendHostCommand := TRUE;
END_IF
												
