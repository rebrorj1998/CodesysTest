(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD CheckIfAllHomed : BOOL
VAR_INPUT
END_VAR
VAR
	J : UINT;
	homed : BOOL;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Go through list of homable components and return true if all are homed OR if component isn't active
FOR J:= 0 TO _TotalObj - 1 DO
	homed := CheckIfHomed(Collection[J]);
END_FOR
CheckIfAllHomed := homed;