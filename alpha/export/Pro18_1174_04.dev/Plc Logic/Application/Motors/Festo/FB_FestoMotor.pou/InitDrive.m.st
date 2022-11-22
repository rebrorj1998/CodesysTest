(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE InitDrive
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//Initialize the drive to prepare for a move
CRTL_Axis.EnableDrive := TRUE;
CRTL_Axis.Halt := TRUE;
CRTL_Axis.Stop := TRUE;    
//CRTL_Axis.StartTask := FALSE;
commandSuccessful := FALSE;
