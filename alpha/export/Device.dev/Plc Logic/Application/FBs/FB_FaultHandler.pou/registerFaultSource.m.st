(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD registerFaultSource
VAR_INPUT
     faultSource : REFERENCE TO IFault;
END_VAR

(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
faultSourceList[sourcesInList]:= faultSource;
sourcesInList:= sourcesInList + 1;