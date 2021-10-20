(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD AckAll
VAR_INPUT
END_VAR
VAR
	Cast : IFault;
	Fault : IFault;
	J : UINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// For each active fault in the array, ack it.
FOR J:= 0 TO totalObj - 1 DO
	IF (__QUERYINTERFACE(Collection[J], Cast)) THEN
		Cast.Ack();
	ELSE 
		RETURN;
	END_IF
END_FOR