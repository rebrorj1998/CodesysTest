(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
PROGRAM PLC_PRG
VAR
	_deviceChecker 		: DeviceChecker;
	_deviceController	: DeviceController;		// Care: Set xAckError if an Error occurred during reconfigure.6
	_xExecute			: BOOL;					// rising edge starts the ExemplaryCase
	_xDone				: BOOL;					// Gets TRUE after an ExemplaryCase was performed
	_xConfirm			: BOOL;					// rising edge resets _xDone, eError and _xExecute.
	_eError				: DED.ERROR;			// Error returned from the device controller.
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
_deviceChecker();
_deviceController();

IF _xExecute THEN
	_xExecute := FALSE;
	OutputCard0.Enable := FALSE;
	_xConfirm := DED.CanReconfigure(CVS_G_Series_Rack_);
END_IF

IF HMI.data.bagLength > 30 THEN
	HMI.data.bagLength := 30;
END_IF
oSealWire := iBagEdgePhotoeye;