

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



METHOD Retract

extendOutput := FALSE;
retractOutput := TRUE;

METHOD Extend

extendOutput := TRUE;
retractOutput := FALSE;

METHOD Execute

//Do nothing