

FUNCTION ExtendLPIfPossible : BOOL
VAR_INPUT
	device : IAllObjects;
END_VAR
VAR
	extendLowPressureDevice : IExtendLowPressure;
END_VAR

//	Function: ExtendLPIfPossible()
//	Description: Helper function
//				 Pass in a device that is controlled byt a SV - extend at low pressure if possible
//	Created by: Ben Hess
//	Created Date: June 27th, 2019

IF (__QUERYINTERFACE(device, extendLowPressureDevice)) THEN
	extendLowPressureDevice.ExtendLowPressure();
	ExtendLPIfPossible := TRUE;
ELSE
	ExtendLPIfPossible := FALSE;
END_IF