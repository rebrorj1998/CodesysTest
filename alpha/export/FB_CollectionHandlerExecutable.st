

FUNCTION_BLOCK FB_CollectionHandlerExecutable
VAR_INPUT
END_VAR
VAR
	Collection: ARRAY[0..GlobalObjects.MAX_EXECUTEABLE] OF IExecuteAutomatically; // object array
	ObjNames   : ARRAY[0..GlobalObjects.MAX_EXECUTEABLE] OF STRING;
	_ArrayOver   : BOOL;
	_BadObj      : INT;
	_DupeObj   : INT;
	_OverObj   : INT;
	_TotalObj   : UINT;
END_VAR
//	Function Block: FB_CollectionHandlerExecutable
//	Description: This collection handler stores executable FB's to an array 
//				 and has a method to execute them all on demand
//	Created by: Ben Hess
//	Created Date: Friday, September 7, 2018


METHOD ExecuteAll
VAR_INPUT
END_VAR
VAR
	Cast : IExecuteAutomatically;
	J : UINT;
END_VAR
// For each executable objest in the array, run its "Execute()" method
FOR J:= 0 TO _TotalObj - 1 DO
	IF (__QUERYINTERFACE(Collection[J], Cast)) THEN
		Cast.Execute();
	ELSE 
		RETURN;
	END_IF
END_FOR

METHOD AddObject
VAR_INPUT
	Obj   : IExecuteAutomatically;
END_VAR
VAR
	I   : UINT;
	J : UINT;
END_VAR
// Add the active fault to the array 
FOR J:= 0 TO _TotalObj DO
	IF Collection[J] = Obj THEN
		// object pointer matches - it's already in here
		RETURN;
	END_IF
END_FOR
   
IF _TotalObj < GlobalObjects.MAX_EXECUTEABLE THEN
	Collection[_TotalObj]:= Obj;
	ObjNames[_TotalObj]:= Obj.InstanceName;
	_TotalObj:= _TotalObj + 1;
ELSE
	_ArrayOver:= TRUE;
	_OverObj:= _OverObj + 1;
END_IF