(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CollectionHandleMachineComponents
VAR_INPUT
END_VAR
VAR
	Collection: ARRAY[0..GlobalObjects.MAX_COMPONENTS] OF IComponent; // object array
	ObjNames   : ARRAY[0..GlobalObjects.MAX_COMPONENTS] OF STRING;
	_ArrayOver   : BOOL;
	_BadObj      : INT;
	_DupeObj   : INT;
	_OverObj   : INT;
	_TotalObj   : UINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_CollectionHandlerExecutable
//	Description: This collection handler stores executable FB's to an array 
//				 and has a method to execute them all on demand
//	Created by: Ben Hess
//	Created Date: Friday, September 7, 2018
