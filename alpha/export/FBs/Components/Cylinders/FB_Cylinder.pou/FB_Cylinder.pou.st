(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_Cylinder IMPLEMENTS ICylinder
VAR_INPUT
    mode : DEVICE_MODES;
END_VAR
VAR_OUTPUT
    extendedStatus : BOOL;
    retractedStatus : BOOL;
    extendOutput : BOOL;
    retractOutput : BOOL;
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
