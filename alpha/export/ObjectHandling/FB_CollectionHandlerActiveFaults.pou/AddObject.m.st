(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD AddObject
VAR_INPUT
	obj   : IFault;
END_VAR
VAR
	_j : UINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Add the active fault to the array 
FOR _j:= 0 TO totalObj DO
	IF Collection[_j] = obj THEN
		// object pointer matches - it's already in here
		RETURN;
	END_IF
END_FOR

// 
IF totalObj < GlobalObjects.MAX_FAULTS THEN
	Collection[totalObj]:= obj;
	objNames[totalObj]:= obj.InstanceName;
	totalObj:= totalObj + 1;
ELSE
	_ArrayOver:= TRUE;
	_OverObj:= _OverObj + 1;
END_IF
faultActive := TRUE;