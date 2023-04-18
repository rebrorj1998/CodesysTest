(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD SetSlaveMotorToTorqueMode
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
_sclCommand := 16#534F; // Torque Mode
_parameter1 := 16#4CB2; // Torque On
_commands.SendHostCommand := TRUE;