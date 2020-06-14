(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'global_init_slot' := '49995'}
VAR_GLOBAL CONSTANT
	MAX_OBJECTS : UINT := 750;
	MAX_CYLINDERS : UINT := 20;
	MAX_MOTORS : UINT := 10;
	MAX_FAULTS : UINT := 300;
	MAX_LOGS : UINT := 100;
	MAX_LOGGABLE : UINT := 500;
	MAX_EXECUTEABLE : UINT := 300;
	MAX_COMPONENTS : UINT := 50;
END_VAR

VAR_GLOBAL
	CollectionOfAllObjects : FB_CollectionHandlerAll; 
	CollectionOfFaults : FB_CollectionHandlerFaults; 
	CollectionOfCylinders : FB_CollectionHandlerCylinders;
	CollectionOfPositionableMotors : FB_CollectionHandlerPositionableMotors;
	CollectionOfActiveFaults : FB_CollectionHandlerActiveFaults; 
	CollectionOfLogs : FB_CollectionHandlerLogs; 
	CollectionOfLoggable : FB_CollectionHandlerLoggable;
	CollectionOfExecutable : FB_CollectionHandlerExecutable;
	CollectionOfInitialzable : FB_CollectionHandlerInitializable;
	CollectionOfComponents : FB_CollectionHandleMachineComponents;
END_VAR