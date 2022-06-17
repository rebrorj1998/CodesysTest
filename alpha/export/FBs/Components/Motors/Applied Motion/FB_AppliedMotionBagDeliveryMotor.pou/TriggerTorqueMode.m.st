(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD TriggerTorqueMode
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF EIP THEN
	parameter1 := TORQUE_MODE_PARAM_ID;
	commands.SendQAndExecute := TRUE;
ELSE
	sclCommand := SCL_SO; 
	parameter1 := O2_L;
	commandSuccessful := FALSE;
	commands.SendHostCommand := TRUE;
END_IF
												
