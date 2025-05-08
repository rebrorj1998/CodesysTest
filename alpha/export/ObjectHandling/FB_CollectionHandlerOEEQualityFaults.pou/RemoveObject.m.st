(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD RemoveObject
VAR_INPUT
	obj : IFault;
END_VAR
VAR
	_i : INT;
	_j : INT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FOR _i:= 0 TO totalObj DO
	IF collection[_i] = obj THEN
		// object pointer matches - get rid of it
		FOR _j := _i TO totalObj DO
			collection[_J] := collection[_j+1];
			_objNames[_J]:= _objNames[_j+1]; 
		END_FOR
		totalObj := totalObj - 1;
		IF totalObj = 0 THEN
			faultExempt := FALSE;
		END_IF
		RETURN;
	END_IF
END_FOR