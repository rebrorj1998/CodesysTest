

FUNCTION_BLOCK FB_CollectionHandlerFaults
VAR_INPUT
END_VAR
VAR
	Collection: ARRAY[0..GlobalObjects.MAX_FAULTS] OF IFault; // object array
	ObjNames   : ARRAY[0..GlobalObjects.MAX_FAULTS] OF STRING;
	faults : ARRAY[0..GlobalObjects.MAX_FAULTS] OF HMIFaultType;
	_ArrayOver   : BOOL;
	_BadObj      : INT;
	_DupeObj   : INT;
	_OverObj   : INT;
	_TotalObj   : UINT;
	_InitFaultList : BOOL;
END_VAR


METHOD FaultUpdateForHMI
VAR_INPUT
END_VAR
VAR
	I : UINT;
END_VAR
FOR I:= 0 TO _TotalObj - 1 DO
	IF NOT _InitFaultList THEN
		faults[I].name := Collection[I].InstanceName;
	END_IF
	faults[I].active := Collection[I].FaultActive;
END_FOR
_InitFaultList := TRUE;

METHOD AddObject
VAR_INPUT
	Obj   : IFault;
END_VAR
VAR
	J   : UINT;
END_VAR
FOR J:= 0 TO _TotalObj DO
	IF Collection[J] = Obj THEN
		// object pointer matches - dupe!
		_DupeObj:= _DupeObj + 1;
		RETURN;
	END_IF
END_FOR
   
IF _TotalObj < GlobalObjects.MAX_FAULTS THEN
	Collection[_TotalObj]:= Obj;
	ObjNames[_TotalObj]:= Obj.InstanceName;
	_TotalObj:= _TotalObj + 1;
ELSE
	_ArrayOver:= TRUE;
	_OverObj:= _OverObj + 1;
END_IF