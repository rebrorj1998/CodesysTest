(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD ResetAll
VAR_INPUT
END_VAR
VAR
	J : UINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Reset all components
FOR J:= 0 TO _TotalObj - 1 DO
	Collection[J].Reset();
END_FOR