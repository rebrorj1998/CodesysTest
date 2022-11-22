(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD RemoveObject
VAR_INPUT
	Obj   : IFault;
END_VAR

VAR
	I   : UINT;
	J : UINT;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FOR I:= 0 TO totalObj DO
	IF Collection[I] = Obj THEN
		// object pointer matches - get rid of it
		FOR J := I TO totalObj DO
			Collection[J] := Collection[J+1];
			ObjNames[J]:= ObjNames[J+1]; 
		END_FOR
		totalObj := totalObj - 1;
		IF totalObj = 0 THEN
			faultActive := FALSE;
		END_IF
		RETURN;
	END_IF
END_FOR