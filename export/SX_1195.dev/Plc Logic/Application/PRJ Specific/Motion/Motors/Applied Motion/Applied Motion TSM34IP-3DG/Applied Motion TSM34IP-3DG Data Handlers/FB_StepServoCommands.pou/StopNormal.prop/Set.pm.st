(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF commandSuccessful THEN
	IF _previousCommandWord.15 <> 0 THEN
		_previousCommandWord := 0;
	ELSE
		commandSuccessful := FALSE;
		_stopAndKillNormal := StopNormal;
	END_IF
END_IF
