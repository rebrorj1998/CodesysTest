(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CollectionHandlerLoggable
VAR_INPUT

END_VAR
VAR
	Collection: ARRAY[0..GlobalObjects.MAX_LOGGABLE] OF ILoggable; // object array
	ObjNames   : ARRAY[0..GlobalObjects.MAX_LOGGABLE] OF STRING;
	_ArrayOver   : BOOL;
	_BadObj      : INT;
	_DupeObj   : INT;
	_OverObj   : INT;
	_TotalObj   : UINT;
	_internalLogger : REFERENCE TO IMachineLogger;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_CollectionHandlerLoggable
//	Description: This collection handler takes in loggable objects and registers them with a logger.  The FirstScan function should trigger the 
//				 RegisterAll() method to register all loggable objects with a logger
//	Created by: Ben Hess
//	Created Date: Tuesday, September 11, 2018
