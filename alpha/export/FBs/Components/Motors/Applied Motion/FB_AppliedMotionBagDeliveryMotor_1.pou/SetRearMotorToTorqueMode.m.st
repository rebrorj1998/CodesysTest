(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD SetRearMotorToTorqueMode
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
sclCommand := 16#534F; // Output on
parameter1 := 16#4CB2;														
commandSuccessful := FALSE;
commands.SendHostCommand := TRUE;