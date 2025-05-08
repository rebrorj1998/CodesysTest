(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD AddObject
VAR_INPUT
	obj : IFault;
END_VAR
VAR
	_j : INT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Add the active fault to the array 
FOR _j := 0 TO totalObj DO
	IF collection[_j] = Obj THEN
		// object pointer matches - it's already in here
		RETURN;
	END_IF
END_FOR
   
IF totalObj < GlobalObjects.MAX_FAULTS THEN
	collection[totalObj]:= Obj;
	_objNames[totalObj]:= Obj.InstanceName;
	totalObj:= totalObj + 1;
END_IF
faultPassive := TRUE;