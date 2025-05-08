(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'global_init_slot' := '49995'}
VAR_GLOBAL CONSTANT
	MAX_OBJECTS : DINT := 1000;
	MAX_CYLINDERS : DINT := 20;
	MAX_MOTORS : DINT := 10;
	MAX_FAULTS : DINT := 500;
	MAX_LOGS : DINT := 100;
	MAX_LOGGABLE : DINT := 500;
	MAX_EXECUTEABLE : DINT := 300;
	OEE_EXEMPT_LIST_LENGTH : DINT := 10;
	OEE_QUALITY_LIST_LENGTH : DINT := 10;
	PASSIVE_EXEMPT_LIST_LENGTH : INT := 3;
END_VAR

VAR_GLOBAL
	CollectionOfAllObjects : FB_CollectionHandlerAll; 
	CollectionOfFaults : FB_CollectionHandlerFaults; 
// 	CollectionOfCylinders : FB_CollectionHandlerCylinders;
// 	CollectionOfPositionableMotors : FB_CollectionHandlerPositionableMotors;
	CollectionOfActiveFaults : FB_CollectionHandlerActiveFaults; 
	CollectionOfPassiveFaults : FB_CollectionHandlerPassiveFaults;
	CollectionOfPassiveExemptFaults : FB_CollectionHandlerPassiveFaults;
	CollectionOfOEEExemptFaults : FB_CollectionHandlerOEEExemptFaults;
	CollectionOfLogs : FB_CollectionHandlerLogs; 
	CollectionOfLoggable : FB_CollectionHandlerLoggable;
	CollectionOfExecutable : FB_CollectionHandlerExecutable;
	CollectionOfInitialzable : FB_CollectionHandlerInitializable;
	OEEExemptList : ARRAY [1..OEE_EXEMPT_LIST_LENGTH] OF STRING := ['Pressure Bar Obstruction Detected', 
																	'Barcode Verification Failed', 
																	'Bag Tension Fault',
																	'Print and Apply Timed Out',
																	'Print and Apply Faulted'];
																	
	OEEQualityList : ARRAY [1..OEE_QUALITY_LIST_LENGTH] OF STRING := ['Pressure Bar Obstruction Detected', 
																	'Barcode Verification Failed', 
																	'Bag Tension Fault',
																	'Print and Apply Timed Out',
																	'Print and Apply Faulted'];
																	
	passiveList : ARRAY [1..PASSIVE_EXEMPT_LIST_LENGTH] OF STRING :=   ['Pressure Bar Obstruction Detected', 
																		'Barcode Verification Failed',
																		'Opened Bag was Removed'];
	Reversing: INT;
END_VAR