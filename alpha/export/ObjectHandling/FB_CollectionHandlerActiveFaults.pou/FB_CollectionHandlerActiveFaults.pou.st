(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CollectionHandlerActiveFaults
VAR_INPUT
END_VAR
VAR
	Collection: ARRAY[0..GlobalObjects.MAX_FAULTS] OF IFault; // object array
	ObjNames   : ARRAY[0..GlobalObjects.MAX_FAULTS] OF STRING;
	_ArrayOver   : BOOL;
	_BadObj      : INT;
	_DupeObj   : INT;
	_OverObj   : INT;
END_VAR
VAR_OUTPUT
	totalObj   : UINT;
	faultActive : BOOL;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_CollectionHandlerActiveFaults
//	Description: This collection handler adds and removes active faults to an array
//				 The add and remove methods are called from FB_Fault
//	Created by: Tom Jacobs
//	Created Date: Friday, September 7, 2018