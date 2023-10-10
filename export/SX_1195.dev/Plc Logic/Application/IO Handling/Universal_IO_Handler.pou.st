(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK Universal_IO_Handler
VAR_INPUT
	initSignal: universalIOObject;
END_VAR
VAR_IN_OUT
	mappedSignal:BOOL;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
mappedSignal:=initSignal.discreteSignal;
