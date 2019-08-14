

FUNCTION_BLOCK FB_CollectionHandlerInitializable
VAR_INPUT

END_VAR
VAR
	Collection: ARRAY[0..GlobalObjects.MAX_LOGGABLE] OF IInitializable; // object array
	ObjNames   : ARRAY[0..GlobalObjects.MAX_LOGGABLE] OF STRING;
	_ArrayOver   : BOOL;
	_BadObj      : INT;
	_DupeObj   : INT;
	_OverObj   : INT;
	_TotalObj   : UINT;
END_VAR
//	Function Block: FB_CollectionHandlerLoggable
//	Description: This collection handler takes in loggable objects and registers them with a logger.  The FirstScan function should trigger the 
//				 RegisterAll() method to register all loggable objects with a logger
//	Created by: Ben Hess
//	Created Date: Tuesday, September 11, 2018


METHOD AddObject
VAR_INPUT
	Obj   : IInitializable;
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
   
IF _TotalObj < GlobalObjects.MAX_LOGGABLE THEN
	Collection[_TotalObj]:= Obj;
	ObjNames[_TotalObj]:= Obj.InstanceName;
	_TotalObj:= _TotalObj + 1;
ELSE
	_ArrayOver:= TRUE;
	_OverObj:= _OverObj + 1;
END_IF

METHOD InitializeAll
VAR_INPUT
	
END_VAR
VAR
	J : UINT;
	Cast : IInitializable;
END_VAR

FOR J:= 0 TO _TotalObj - 1 DO
	IF (__QUERYINTERFACE(Collection[J], Cast)) THEN
		Cast.Initialize();
	ELSE 
		RETURN;
	END_IF
END_FOR