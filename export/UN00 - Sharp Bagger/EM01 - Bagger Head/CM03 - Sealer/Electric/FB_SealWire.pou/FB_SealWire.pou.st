(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_SealWire EXTENDS FB_BasicSealer
VAR_INPUT
END_VAR
VAR_OUTPUT
	sealWireOutput : BOOL;
END_VAR
VAR

END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();



IF sealActive THEN
	sealWireOutput := TRUE;
ELSE
	sealWireOutput := FALSE;
END_IF