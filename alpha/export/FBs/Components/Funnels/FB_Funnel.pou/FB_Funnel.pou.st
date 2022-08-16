(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_Funnel EXTENDS FB_BaseComponent
VAR_INPUT
 	iOpened : BOOL;			 		  // Open sensor input
 	iClosed : BOOL;	     	 		  // Closed sensor input
	feedback : eActuatorFeedbackType; // Funnel type selected
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
	_cylinderFault : FB_CylinderFaults;                 // Cylinder Faults
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
	_reset := FALSE;
	_openRequest := FALSE;
	_closeRequest := FALSE;
	_openingTimer.IN := FALSE;
	_closingTimer.IN := FALSE;
	_openingDelayTimer.IN := FALSE;
	oClose := FALSE;
	oOpen := FALSE;
END_IF

//;
IF feedback <> eActuatorFeedbackType.None THEN
	opened := iOpened;
	closed := iClosed;
ELSE
	_openingTimer.IN := oOpen;
	_closingTimer.IN := oClose;
	opened := _openingTimer.Q;
	closed := _closingTimer.Q;
END_IF

// Fault Timer for Failed TO reach open/closed sensors
_cylinderFault(
	feedback := feedback,
	extendCommand := oOpen, 
	extendedInput := iOpened, 
	retractCommand := oClose, 
	retractedInput := iClosed, 
	faultTime:= T#1S, 
	failToExtend=> failToClose.faultTrigger, 
	failToRetract=> failToOpen.faultTrigger
);