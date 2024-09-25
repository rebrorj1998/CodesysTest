(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PRIVATE OutputSelected : INT
VAR_INPUT
	output : AuxOutputSelection;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
OutputSelected := 0;
IF factorySelection.cfgOutput1Selection = output THEN
	OutputSelected := 1;
ELSIF factorySelection.cfgOutput2Selection = output THEN
	OutputSelected := 2;
ELSIF factorySelection.cfgOutput3Selection = output THEN
	OutputSelected := 3;
ELSIF factorySelection.cfgOutput4Selection = output THEN
	OutputSelected := 4;
END_IF