(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CollectionHandlerActiveFaults
VAR_INPUT
END_VAR
VAR_OUTPUT
	totalObj : UINT;
	faultActive : BOOL;
	objNames : ARRAY[0..GlobalObjects.MAX_FAULTS] OF STRING;
	collection : ARRAY[0..GlobalObjects.MAX_FAULTS] OF IFault;
END_VAR
VAR
	
	_arrayOver : BOOL;
	_overObj : INT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_CollectionHandlerActiveFaults
//	Description: This collection handler adds and removes active faults to an array
//				 The add and remove methods are called from FB_Fault
//	Created by: 
//	Created Date: Friday, September 7, 2018