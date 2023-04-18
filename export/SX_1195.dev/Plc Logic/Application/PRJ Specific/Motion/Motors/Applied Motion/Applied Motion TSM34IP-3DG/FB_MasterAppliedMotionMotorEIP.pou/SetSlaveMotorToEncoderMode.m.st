(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD SetSlaveMotorToEncoderMode

(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
_sclCommand := 16#534F; // Torque Mode
_parameter1 := 16#48B2; // Torque Off
_commands.SendHostCommand := TRUE;