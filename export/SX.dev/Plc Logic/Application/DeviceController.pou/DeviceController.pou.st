(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
(* 
	With the DeviceController it is possible to start/stop/reset a device or to enable/disable a device/subtree.
	
	IMPORTANT NOTE: Enabling/Disabling a device is always a two-step process:
		1. Set Enable := TRUE/FALSE at all devices you'd like to change. (Note: A FALSE value will be inherited by children.)
		2. Call DED.Reconfigure for the top most node supporting reconfigure functionality. This can be checked with "CanReconfigure" function.
		There is more information in the documentation of Reconfigure function block in caa device diagnosis library.
*)
FUNCTION_BLOCK DeviceController
VAR_INPUT
	xAckError				: BOOL;	// Acknowledge if eError <> ERROR.NO_ERROR. 
END_VAR
VAR_OUTPUT
	xReconfigureActive		: BOOL;
	eError					: DED.ERROR;
END_VAR
VAR
	_iState					: INT;
	_reconfigure			: DED.Reconfigure;
	_itfNodeToReconfigure 	: DED.INode;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
CASE _iState OF
0:		// idle... wait until a method from "Enable/Disable" category is called 
	xReconfigureActive := FALSE;
10:		// perform reconfigure

	xReconfigureActive := TRUE;
	
	_reconfigure(
		xExecute 	:= TRUE,  
		itfNode 	:= _itfNodeToReconfigure, 
		eError 		=> eError
		);
		
	// reconfigure successfully done. Reset _reconfigure and move to idle state 
	IF _reconfigure.xDone THEN
		_reconfigure(xExecute := FALSE);
		_itfNodeToReconfigure := 0;
		_iState := 0;
	// an error happened performing a reconfigure. Reset _reconfigure and move to error state
	ELSIF _reconfigure.xError THEN
		_reconfigure(xExecute := FALSE);
		_itfNodeToReconfigure := 0;
		_iState := 100;
	END_IF
100:	// reconfigure failed. Wait for xAckError.

	IF xAckError THEN
		// reset eError output
		eError := DED.ERROR.NO_ERROR;
		_iState := 0;
	END_IF
	
END_CASE