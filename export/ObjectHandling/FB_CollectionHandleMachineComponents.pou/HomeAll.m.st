(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD HomeAll
VAR_INPUT
END_VAR
VAR
	Cast : IHomable;
	J : UINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// For each homable objest in the array, run its "HomeNow()" method
FOR J:= 0 TO _TotalObj - 1 DO
	IF (__QUERYINTERFACE(Collection[J], Cast)) THEN
		Cast.HomeNow();
	ELSE 
		RETURN;
	END_IF
END_FOR
