

FUNCTION ExhaustIfPossible : BOOL  // Attempts to exhaust SV, returns true if exhaust commanded
VAR_INPUT
	device : IAllObjects;
END_VAR
VAR
	exhaustableDevice : IExhaustable;
END_VAR

//	Function: ExhaustIfPossible()
//	Description: Helper function
//				 Pass in a device that is controlled byt a SV - exhaust if possible
//	Created by: Ben Hess
//	Created Date: June 25th, 2019

IF (__QUERYINTERFACE(device, exhaustableDevice)) THEN
	exhaustableDevice.Exhaust();
	ExhaustIfPossible := TRUE;
ELSE
	ExhaustIfPossible := FALSE;
END_IF

FUNCTION ExhaustIfPossible : BOOL  // Attempts to exhaust SV, returns true if exhaust commanded
VAR_INPUT
	device : IAllObjects;
END_VAR
VAR
	exhaustableDevice : IExhaustable;
END_VAR

//	Function: ExhaustIfPossible()
//	Description: Helper function
//				 Pass in a device that is controlled byt a SV - exhaust if possible
//	Created by: Ben Hess
//	Created Date: June 25th, 2019

IF (__QUERYINTERFACE(device, exhaustableDevice)) THEN
	exhaustableDevice.Exhaust();
	ExhaustIfPossible := TRUE;
ELSE
	ExhaustIfPossible := FALSE;
END_IF