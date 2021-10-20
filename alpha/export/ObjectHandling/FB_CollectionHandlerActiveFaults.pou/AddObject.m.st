(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD AddObject
VAR_INPUT
	Obj   : IFault;
END_VAR
VAR
	I   : UINT;
	J : UINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Add the active fault to the array 
FOR J:= 0 TO totalObj DO
	IF Collection[J] = Obj THEN
		// object pointer matches - it's already in here
		RETURN;
	END_IF
END_FOR
   
IF totalObj < GlobalObjects.MAX_FAULTS THEN
	Collection[totalObj]:= Obj;
	ObjNames[totalObj]:= Obj.InstanceName;
	totalObj:= totalObj + 1;
ELSE
	_ArrayOver:= TRUE;
	_OverObj:= _OverObj + 1;
END_IF
faultActive := TRUE;