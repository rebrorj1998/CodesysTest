

FUNCTION_BLOCK FB_FaultHandler
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
    faultSourceList : ARRAY[0..100] OF IFault;
    sourcesInList : INT;
END_VAR



METHOD registerFaultSource
VAR_INPUT
     faultSource : REFERENCE TO IFault;
END_VAR


faultSourceList[sourcesInList]:= faultSource;
sourcesInList:= sourcesInList + 1;