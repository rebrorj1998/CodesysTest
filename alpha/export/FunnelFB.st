

FUNCTION_BLOCK FunnelFB EXTENDS BaseComponentFB
VAR_INPUT
	sensorsInstalled : BOOL;
	openSensor : BOOL;
	closedSensor : BOOL;
END_VAR
VAR_OUTPUT
	opened : BOOL;
	closed : BOOL;
	closeOutput : BOOL;
	openOutput : BOOL;
	failToOpen : FB_Fault(name := 'Failed to Open');
	failToClose : FB_Fault(name := 'Failed to Close');
END_VAR
VAR
	_delayTimeInMS : UINT; 			// Delay before open in mS
	_closeReq : BOOL;
	_openReq : BOOL;
	openDelay : Standard.TON;
	openingTimer : Standard.TON;
	closingTimer : Standard.TON;
	faultTimer : FB_CylinderFaults;
END_VAR

SUPER^();

openingTimer(IN := openOutput);
closingTimer(IN := closeOutput);

IF sensorsInstalled THEN
	opened := openSensor;
	closed := closedSensor;
ELSE
	opened := openingTimer.Q;
	closed := closingTimer.Q;
END_IF

IF enable THEN
	IF _closeReq THEN
		closeOutput := TRUE;
		openOutput := FALSE;
		_closeReq := FALSE;
	ELSIF _openReq THEN
		closeOutput := FALSE;
		openOutput := TRUE;
		_openReq := FALSE;
	END_IF
ELSE
	closeOutput := FALSE;
	openOutput := FALSE;
	_openReq := FALSE;
	_closeReq := FALSE;
END_IF

faultTimer(
	enable:= THIS^.enable AND sensorsInstalled, 
	extendCommand:= closeOutput, 
	extendedInput:= closedSensor, 
	retractCommand:= openOutput, 
	retractedInput:= openSensor, 
	faultTime:= T#1S, 
	failToExtend=> failToClose.faultTrigger, 
	failToRetract=> failToOpen.faultTrigger);

METHOD OpenNow : BOOL
VAR_INPUT
END_VAR

_openReq := TRUE;

METHOD CloseNow : BOOL
VAR_INPUT
END_VAR

_closeReq := TRUE;

PROPERTY DelaySetting : UINT

PROPERTY ClosingTime : REAL

PROPERTY OpeningTime : REAL