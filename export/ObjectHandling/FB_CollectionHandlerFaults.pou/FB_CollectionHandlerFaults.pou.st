(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
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
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
