(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD AckAll
VAR_INPUT
END_VAR
VAR
	_cast : IFault;
	_fault : IFault;
	_j : INT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// For each active fault in the array, ack it.
FOR _j:= 0 TO totalObj - 1 DO
	IF (__QUERYINTERFACE(collection[_j], _cast)) THEN
		_cast.Ack();
	ELSE 
		RETURN;
	END_IF
END_FOR