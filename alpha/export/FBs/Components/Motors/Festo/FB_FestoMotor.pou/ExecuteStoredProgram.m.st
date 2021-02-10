(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD ExecuteStoredProgram
VAR_INPUT
    (*Program number to execute*)
    programNumber    : INT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
InitDrive();
IF InPosition AND CRTL_Axis.ActualRecordNo = programNumber THEN
    commandSuccessful := TRUE;
ELSE
    CRTL_Axis.RecordNo := programNumber;
    _sendStart := TRUE;
END_IF