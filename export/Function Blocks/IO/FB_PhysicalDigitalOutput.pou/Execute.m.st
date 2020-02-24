(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Execute
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
outputONS(CLK := Q);

IF __ISVALIDREF(refoutput) THEN
	IF _simulate THEN 
		refOutput := FALSE;
	ELSE
		refOutput := Q;
	END_IF
END_IF



IF outputONS.OSR THEN
    _logger.AddLogItem(CONCAT(_prefix, 'On'));
END_IF

IF outputONS.OSF THEN
    _logger.AddLogItem(CONCAT(_prefix, 'Off'));
END_IF