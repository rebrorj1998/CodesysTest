(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD SetTorqueValue
VAR_INPUT
	torque : DINT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
sclCommand := 16#4743; // GC (Current Command)
parameter1 := torque;
															
commandSuccessful := FALSE;
commands.SendHostCommand := TRUE;