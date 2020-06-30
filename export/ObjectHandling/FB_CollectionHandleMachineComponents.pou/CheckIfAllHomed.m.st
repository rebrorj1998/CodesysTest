(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD CheckIfAllHomed : BOOL
VAR_INPUT
END_VAR
VAR
	J : UINT;
	notHomed : BOOL;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Go through list of homable components and return true if all are homed OR if component isn't active
FOR J:= 0 TO _TotalObj - 1 DO
	IF NOT CheckIfHomed(Collection[J]) THEN
		notHomed := TRUE;
	END_IF
END_FOR
CheckIfAllHomed := NOT notHomed;