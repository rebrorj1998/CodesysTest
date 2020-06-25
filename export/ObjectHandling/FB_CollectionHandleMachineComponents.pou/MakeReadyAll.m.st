(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD MakeReadyAll : BOOL
VAR
	J : UINT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Reset all components
FOR J:= 0 TO _TotalObj - 1 DO
	IF NOT Collection[J].Ready THEN
		Collection[J].MakeReady();
	END_IF
END_FOR