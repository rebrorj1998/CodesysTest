(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Finds an unit mode by name.
{attribute 'hide'} 
METHOD PRIVATE FindMode : USINT
VAR_INPUT
	sName: STRING; // Name od the unit mode
END_VAR
VAR
	usi: USINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FOR usi := 1 TO usiNumberOfUMs DO
	IF sName = apum[usi].Name THEN
		FindMode := usi;
		RETURN;
	END_IF
END_FOR
FindMode := gc_usiMaxModes+1;