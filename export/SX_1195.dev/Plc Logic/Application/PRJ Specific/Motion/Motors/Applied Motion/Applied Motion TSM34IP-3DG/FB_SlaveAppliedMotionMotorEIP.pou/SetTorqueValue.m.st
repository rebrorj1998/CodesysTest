(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD SetTorqueValue : BOOL
VAR_INPUT
	torque : REAL;
END_VAR
VAR CONSTANT
	UPDATE_TORQUE_CMD : DINT := 16#4743;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
_sclCommand := UPDATE_TORQUE_CMD; 
_parameter1 := TO_DINT(torque * 100);
_commands.SendHostCommand := TRUE;

