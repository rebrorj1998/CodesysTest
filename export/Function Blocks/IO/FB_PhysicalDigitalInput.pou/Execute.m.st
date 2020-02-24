(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Execute
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF NOT __ISVALIDREF(in) THEN
	RETURN;
END_IF

debounceTimer(IN := (in AND NOT simulate) OR (simulate AND simValue) AND debounceEnable, PT := REAL_TO_TIME(debounceTime * 1000));
inputONS();

IF debounceEnable THEN
	Active := debounceTimer.Q;
ELSE
	IF simulate THEN
		Active := simValue;
		inputONS.CLK := simValue;
	ELSE
		Active := in;
		inputONS.CLK := in;
		
	END_IF
END_IF


IF inputONS.OSR THEN
    _logger.AddLogItem(CONCAT(_prefix, 'On'));
END_IF

IF inputONS.OSF THEN
    _logger.AddLogItem(CONCAT(_prefix, 'Off'));
END_IF