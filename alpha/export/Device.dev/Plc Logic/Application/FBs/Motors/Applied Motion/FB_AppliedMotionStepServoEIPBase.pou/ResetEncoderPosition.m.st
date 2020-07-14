(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD ResetEncoderPosition
VAR_INPUT
	position : DINT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
sclCommand := 16#5350; // SP (Set Position)
parameter1 := position;
															
commandSuccessful := FALSE;
commands.SendHostCommand := TRUE;