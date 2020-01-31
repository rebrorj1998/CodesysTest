

FUNCTION_BLOCK BarcodeReaderFB EXTENDS BaseComponentFB
VAR_INPUT
	feedSpeed : REAL;
	positionOffset : REAL;
	distanceToScan : REAL;
	readGoodInput : BOOL;
	badReadFaultCountSetting : UDINT;
END_VAR	
VAR_OUTPUT
	triggerScannerOutput : BOOL;
	xBusy : BOOL;
	xDone : BOOL;
	currentGoodReadCount : UDINT;
	currentBadReadCount : UDINT;
	barcodeFault : BOOL;
END_VAR
VAR
	_goodRead : BOOL;
	_badread : BOOL;
	_trigger : BOOL;
	state : BCR_STATES;
	waitForReadTimer : Standard.TON;
	positionOffsetDelay : Standard.TON;
END_VAR
VAR CONSTANT
	MILLISECONDS_IN_SECOND : INT := 1000;
END_VAR

//    Function Block: BarcodeReaderFB
//    Description: Trigger the barcode verifier and receive a "Barcode OK" signal, or nothing which indicates no read.
//    Created by: Ben Hess
//    Created Date: January 29th, 2020

// Setup timers for reading offset and scanning distance
IF positionOffset > 0 THEN
	positionOffsetDelay(PT := TO_TIME(MILLISECONDS_IN_SECOND / (feedSpeed / positionOffset)) + T#120ms);
ELSE
	positionOffsetDelay(PT := T#0S);
END_IF

IF distanceToScan > 0 THEN
	waitForReadTimer(PT := TO_TIME(MILLISECONDS_IN_SECOND / (feedSpeed / distanceToScan)));
ELSE
	waitForReadTimer(PT := T#0S);
END_IF

IF _reset OR NOT enable THEN
	//
	state := BCR_STATES.Idle;
	barcodeFault := FALSE;
END_IF

CASE state OF
	
	BCR_STATES.Idle:				// Wait for trigger
									triggerScannerOutput := FALSE;
									waitForReadTimer.IN := FALSE;
									positionOffsetDelay.IN := FALSE;
									
									xBusy := FALSE;
									IF _trigger THEN
										state := BCR_STATES.WaitForOffset;
										positionOffsetDelay.IN := TRUE;
										xBusy := TRUE;
										xDone := FALSE;
									END_IF
									
									_trigger := FALSE;
									
	BCR_STATES.WaitForOffset: 		// Wait for offset to trigger read
									IF positionOffsetDelay.Q THEN
										state := BCR_STATES.TriggerReader;
										positionOffsetDelay.IN := FALSE;
									END_IF
									
	BCR_STATES.TriggerReader:		// Trigger the reader and then move to waiting state for result
									triggerScannerOutput := TRUE;
									waitForReadTimer.IN := TRUE;
									state := BCR_STATES.WaitingForResult;
									
	
	BCR_STATES.WaitingForResult:	// Wait for delayToCheckReadStatus timer.  If it times out we did not get a good read
									IF readGoodInput THEN
										_goodRead := TRUE;
										_badread := FALSE;
										currentGoodReadCount := currentGoodReadCount + 1;
										currentBadReadCount := 0;
										xDone := TRUE;
										state := BCR_STATES.Idle;
									ELSIF waitForReadTimer.Q THEN
										_goodRead := FALSE;
										_badread := TRUE;
										currentGoodReadCount := 0;
										currentBadReadCount := currentBadReadCount + 1;
										IF badReadFaultCountSetting > 0 THEN
											IF currentBadReadCount >= badReadFaultCountSetting THEN
												barcodeFault := TRUE;
											END_IF
										END_IF
										xDone := TRUE;
										state := BCR_STATES.Idle;
									END_IF
	
	BCR_STATES.Resetting:
	
END_CASE

SUPER^();

PROPERTY GoodRead : BOOL

METHOD Trigger : BOOL
VAR_INPUT
END_VAR
_trigger := TRUE;

PROPERTY BadRead : BOOL