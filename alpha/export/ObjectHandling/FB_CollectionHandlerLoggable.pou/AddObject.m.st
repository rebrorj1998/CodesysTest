(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD AddObject
VAR_INPUT
	Obj   : ILoggable;
END_VAR
VAR
	J   : UINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FOR J:= 0 TO _TotalObj DO
	IF Collection[J] = Obj THEN
		// object pointer matches - dupe!
		_DupeObj:= _DupeObj + 1;
		RETURN;
	END_IF
END_FOR
   
IF _TotalObj < GlobalObjects.MAX_LOGGABLE THEN
	Collection[_TotalObj]:= Obj;
	ObjNames[_TotalObj]:= Obj.InstanceName;
	_TotalObj:= _TotalObj + 1;
ELSE
	_ArrayOver:= TRUE;
	_OverObj:= _OverObj + 1;
END_IF