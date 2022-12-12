(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD private InputActive : BOOL
VAR_INPUT
	inputSelection : AuxInputSelection;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
InputActive := (HMIData.auxIOConfig.cfgInput1Selection = inputSelection AND configIn1) OR
               (HMIData.auxIOConfig.cfgInput2Selection = inputSelection AND configIn2) OR
			   (HMIData.auxIOConfig.cfgInput3Selection = inputSelection AND configIn3) OR
               (HMIData.auxIOConfig.cfgInput4Selection = inputSelection AND configIn4);