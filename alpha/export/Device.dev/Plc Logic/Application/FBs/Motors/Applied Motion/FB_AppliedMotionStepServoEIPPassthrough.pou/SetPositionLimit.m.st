(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD SetPositionLimit
VAR_INPUT
	positionLimit : DINT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
sclCommand := 16#5046; // PF (Position Fault)
parameter1 := positionLimit;
															
commandSuccessful := FALSE;
commands.SendHostCommand := TRUE;