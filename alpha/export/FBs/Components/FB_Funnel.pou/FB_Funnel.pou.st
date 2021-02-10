(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_Funnel EXTENDS FB_BaseComponent
VAR_INPUT
	sensorsInstalled : BOOL;							// Are open/closed sensors installed?
	openSensor : BOOL;									// Open sensor input
	closedSensor : BOOL;								// Closed sensor input
END_VAR	
VAR_OUTPUT
	opened : BOOL;										// Funnel Opened status
	closed : BOOL;										// Funnel Closed status
	closeOutput : BOOL;									// Map to physical close output
	openOutput : BOOL;									// Map to physical open output
	failToOpen : FB_Fault(name := 'Failed to Open');	// Failed to Open fault
	failToClose : FB_Fault(name := 'Failed to Close');	// Failed to Close fault
END_VAR
VAR
	_delayTimeInMS : UINT; 								// Delay before open in mS
	_closeReq : BOOL;									// Close reqested from CloseNow()
	_openReq : BOOL;									// Open requested from OpenNow()
	openDelayTimer : Standard.TON;						// Open delay timer
	openingTimer : Standard.TON;						// Opening timer
	closingTimer : Standard.TON;						// Closing timer
	faultTimer : FB_CylinderFaults;						// Fault timer for open/close faults
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: FunnelFB
//    Description: Funnel
//    Created by: Ben Hess
//    Created Date: November 18th, 2019

IF _reset THEN
	_openReq := FALSE;
	_closeReq := FALSE;
	openingTimer.IN := FALSE;
	closingTimer.IN := FALSE;
	openDelayTimer.IN := FALSE;
END_IF

// Setup timers
openDelayTimer();
openingTimer();
closingTimer();

// Use opening/closing timers for debounce if sensors enabled
// or for actual opening/closing time after command to move if disabled
IF sensorsInstalled THEN
	openingTimer.IN := openSensor;
	closingTimer.IN := closedSensor;
ELSE
	openingTimer.IN := openOutput;
	closingTimer.IN := closeOutput;
END_IF

// Set open/closed status of funnel
opened := openingTimer.Q;
closed := closingTimer.Q;


// Set physical outputs depending on command
IF enable THEN
	IF _closeReq THEN
		closeOutput := TRUE;
		openOutput := FALSE;
		_closeReq := FALSE;
	ELSIF _openReq THEN
		openDelayTimer.IN := TRUE;
		closeOutput := FALSE;
		openOutput := openDelayTimer.Q;
		_openReq := FALSE;
	END_IF
ELSE
	// Turn everything off if disabled
	closeOutput := FALSE;
	openOutput := FALSE;
	_openReq := FALSE;
	_closeReq := FALSE;
	openingTimer.IN := FALSE;
	closingTimer.IN := FALSE;
	openDelayTimer.IN := FALSE;
END_IF

// Fault timer for failed to reach open/closed sensors
faultTimer(
	enable:= THIS^.enable AND sensorsInstalled, 
	extendCommand:= closeOutput, 
	extendedInput:= closedSensor, 
	retractCommand:= openOutput, 
	retractedInput:= openSensor, 
	faultTime:= T#1S, 
	failToExtend=> failToClose.faultTrigger, 
	failToRetract=> failToOpen.faultTrigger);
	
SUPER^();