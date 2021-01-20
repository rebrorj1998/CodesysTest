(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD RegisterAll
VAR_INPUT
	internalLogger : IMachineLogger;
END_VAR
VAR
	I   : UINT;
	J : UINT;
	cast : ILoggable;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FOR J:= 0 TO _TotalObj - 1 DO
	IF (__QUERYINTERFACE(Collection[J], Cast)) THEN
		cast.RegisterLogger(internalLogger := internalLogger);
	ELSE
		RETURN;
	END_IF
END_FOR
  