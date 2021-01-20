(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD AckAll
VAR_INPUT
END_VAR
VAR
	J : UINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FOR J:= 0 TO _TotalObj - 1 DO
	Collection[J].Ack();
END_FOR