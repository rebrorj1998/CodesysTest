(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD ContainsObject : BOOL
VAR_INPUT
	objName : STRING;
END_VAR
VAR
	_i : UINT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Add the active fault to the array 
FOR _i := 0 TO totalObj DO
	IF objNames[_i] = objName THEN
		ContainsObject := TRUE;
		RETURN;
	END_IF
END_FOR
ContainsObject := FALSE;

