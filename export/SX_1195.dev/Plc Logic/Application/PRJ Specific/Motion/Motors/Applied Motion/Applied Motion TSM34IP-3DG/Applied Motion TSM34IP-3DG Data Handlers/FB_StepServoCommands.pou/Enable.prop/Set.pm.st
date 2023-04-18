(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF commandSuccessful THEN
	IF _previousCommandWord.1 <> 0 THEN
		_previousCommandWord := 0;
	ELSE
		commandSuccessful := FALSE;
		_enable := Enable;
	END_IF
END_IF