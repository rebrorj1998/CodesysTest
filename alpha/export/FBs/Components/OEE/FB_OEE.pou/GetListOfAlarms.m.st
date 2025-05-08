(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD GetListOfAlarms : STRING(1000);
VAR_INPUT
END_VAR
VAR
	i : INT;
	_faultString : STRING(1000);
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
_faultString := '';
FOR i := 0 TO 10 DO
	IF collectionOfActiveFaults.objNames[i] <> '' THEN
		_faultString := CONCAT(_faultString, collectionOfActiveFaults.objNames[i]);
		_faultString := CONCAT(_faultString, '|');
	ELSE
		EXIT;
	END_IF
END_FOR
GetListOfAlarms := _faultString;