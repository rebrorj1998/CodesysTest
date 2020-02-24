(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
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
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
