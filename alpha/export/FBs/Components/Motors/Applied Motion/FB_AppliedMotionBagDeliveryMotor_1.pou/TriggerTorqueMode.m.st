(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD TriggerTorqueMode
VAR_INPUT
END_VAR
VAR CONSTANT
	TORQUE_MODE_ID : INT := 2;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
parameter1 := TORQUE_MODE_ID;
commands.SendQAndExecute := TRUE;													
