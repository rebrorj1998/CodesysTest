(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD CheckIfAllReady : BOOL
VAR_INPUT
END_VAR
VAR
	J : UINT;
	notReady : BOOL;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Go through list of homable components and return true if all are homed OR if component isn't active
FOR J:= 0 TO _TotalObj - 1 DO
	IF NOT CheckIfReady(Collection[J]) THEN
		notReady := TRUE;
	END_IF
END_FOR
CheckIfAllReady := NOT notReady;