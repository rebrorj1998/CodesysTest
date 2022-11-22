(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD ExecuteAll
VAR_INPUT
END_VAR
VAR
	Cast : IExecuteAutomatically;
	J : UINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// For each executable objest in the array, run its "Execute()" method
FOR J:= 0 TO _TotalObj - 1 DO
	IF (__QUERYINTERFACE(Collection[J], Cast)) THEN
		Cast.Execute();
	ELSE 
		RETURN;
	END_IF
END_FOR