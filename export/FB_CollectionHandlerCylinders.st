

FUNCTION_BLOCK FB_CollectionHandlerCylinders
VAR_INPUT
END_VAR
VAR
	Collection: ARRAY[0..GlobalObjects.MAX_CYLINDERS] OF ICylinder; // object array
	ObjNames   : ARRAY[0..GlobalObjects.MAX_CYLINDERS] OF STRING;
	_ArrayOver   : BOOL;
	_BadObj      : INT;
	_DupeObj   : INT;
	_OverObj   : INT;
	_TotalObj   : UINT;
END_VAR



METHOD AddObject
VAR_INPUT
	Obj   : ICylinder;
END_VAR
VAR
	Cast: ICylinder;
	J   : UINT;
END_VAR
FOR J:= 0 TO _TotalObj DO
	IF Collection[J] = Obj THEN
		// object pointer matches - dupe!
		_DupeObj:= _DupeObj + 1;
		RETURN;
	END_IF
END_FOR
   
IF _TotalObj < GlobalObjects.MAX_CYLINDERS THEN
	Collection[_TotalObj]:= Obj;
	ObjNames[_TotalObj]:= Obj.InstanceName;
	_TotalObj:= _TotalObj + 1;
ELSE
	_ArrayOver:= TRUE;
	_OverObj:= _OverObj + 1;
END_IF