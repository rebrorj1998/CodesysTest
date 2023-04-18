(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF commandSuccessful THEN
	IF _previousCommandWord.18 <> 0 THEN
		_previousCommandWord := 0;
	ELSE
		commandSuccessful := FALSE;
		_sendHostCommand := SendHostCommand;
	END_IF
END_IF
