(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF commandSuccessful THEN
	IF _previousCommandWord.19 <> 0 THEN
		_previousCommandWord := 0;
	ELSE
		commandSuccessful := FALSE;
		_sendQAndExecute := SendQAndExecute;
	END_IF
END_IF
