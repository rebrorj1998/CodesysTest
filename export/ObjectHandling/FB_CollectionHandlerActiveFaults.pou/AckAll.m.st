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
FOR J:= 0 TO _TotalObj - 1 DO
		Collection[J].Ack();
END_FOR