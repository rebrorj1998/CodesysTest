(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD RemoveObject
VAR_INPUT
	obj   : IFault;
END_VAR
VAR
	_i : UINT;
	_j : UINT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FOR _i:= 0 TO totalObj DO
	IF Collection[_i] = obj THEN
		// object pointer matches - get rid of it
		FOR _j := _i TO totalObj DO
			Collection[_j] := Collection[_j+1];
			objNames[_j]:= objNames[_j+1]; 
		END_FOR
		totalObj := totalObj - 1;
		IF totalObj = 0 THEN
			faultActive := FALSE;
		END_IF
		RETURN;
	END_IF
END_FOR