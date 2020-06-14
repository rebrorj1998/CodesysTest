(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD HomeAll
VAR_INPUT
	
END_VAR
VAR
	J : UINT;
	Cast : IHomable;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FOR J:= 0 TO _TotalObj - 1 DO
	IF (__QUERYINTERFACE(Collection[J], Cast)) THEN
		Cast.HomeNow();
	ELSE 
		RETURN;
	END_IF
END_FOR