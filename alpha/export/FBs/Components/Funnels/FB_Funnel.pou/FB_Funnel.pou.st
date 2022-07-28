(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_Funnel EXTENDS FB_BaseComponent
VAR_INPUT
 	iOpen : BOOL;					// Open sensor input
 	iClosed : BOOL;					// Closed sensor input
	funnelType : FunnelSelection;   // Funnel type selected
	openingDelay : REAL;
	openingDwell : REAL;
	closingDwell : REAL;
END_VAR	
VAR_OUTPUT
	opened : BOOL;										// Funnel Opened status
	closed : BOOL;										// Funnel Closed status
	oClose : BOOL;									    // Map to physical close output
	oOpen : BOOL;									    // Map to physical open output
	failToOpen : FB_Fault(name := 'Failed to Open');	// Failed to Open fault
	failToClose : FB_Fault(name := 'Failed to Close');	// Failed to Close fault
END_VAR
VAR
	_closeRequest : BOOL;								// Close reqested from Close()
	_openRequest : BOOL;								// Open requested from Open()
	_openingDelayTimer : Standard.TON;					// Open delay timer
	_openingTimer : Standard.TON;						// Opening timer
	_closingTimer : Standard.TON;						// Closing timer
	_cylinderFault : FB_CylinderFaults;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: FunnelFB
//    Description: Funnel
//    Created by: Ben Hess
//    Created Date: November 18th, 2019

// 
SUPER^();

// Setup timers
_closingTimer(PT := TO_TIME(closingDwell * 1000));
_openingTimer(PT := TO_TIME(openingDwell * 1000));
_openingDelayTimer(PT := TO_TIME(openingDelay * 1000));

// Turn on Open output after set delay
IF _openingDelayTimer.Q THEN
	_openingDelayTimer.IN := FALSE;
	oOpen := TRUE;
END_IF

//
IF _openRequest THEN
	oClose := FALSE;
	_openRequest := FALSE;
	_openingDelayTimer.IN := TRUE;
ELSIF _closeRequest THEN
	oOpen := FALSE;
	oClose := TRUE;
	_closeRequest := FALSE;
END_IF

//
IF _reset OR NOT enable THEN
	_openRequest := FALSE;
	_closeRequest := FALSE;
	_openingTimer.IN := FALSE;
	_closingTimer.IN := FALSE;
	_openingDelayTimer.IN := FALSE;
	oClose := FALSE;
	oOpen := FALSE;
	_reset := FALSE;
END_IF

//
CASE funnelType OF
	FunnelSelection.FunnelWithoutSensor:
		_cylinderFault.enable := FALSE;
		_openingTimer.IN := oOpen;
		_closingTimer.IN := oClose;
		opened := _openingTimer.Q;
		closed := _closingTimer.Q;
	
	FunnelSelection.FunnelWithSensor:
		_cylinderFault.enable := TRUE;
		_openingTimer.IN := NOT iClosed;
		opened := _openingTimer.Q;
		closed := iClosed;
	
	FunnelSelection.FunnelWithSensors:
		_cylinderFault.enable := TRUE;
		opened := iOpen;
		closed := iClosed;
		
END_CASE

// Fault Timer for Failed TO reach open/closed sensors
_cylinderFault(
	extendCommand := oOpen, 
	extendedInput := iOpen, 
	retractCommand := oClose, 
	retractedInput := iClosed, 
	faultTime:= T#1S, 
	failToExtend=> failToClose.faultTrigger, 
	failToRetract=> failToOpen.faultTrigger
);