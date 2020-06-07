(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_BaseBCV EXTENDS FB_BaseComponent IMPLEMENTS IBarcodeVerifier
VAR_INPUT
	feedSpeed : UDINT;
	positionOffset : REAL;
	distanceToScan : REAL;
	readGoodInput : BOOL;
	badReadInput : BOOL;
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
	state : eBaseBCVStates;
	waitForReadTimer : Standard.TON;
	positionOffsetDelay : Standard.TON;
END_VAR
VAR CONSTANT
	MILLISECONDS_IN_SECOND : INT := 1000;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: BarcodeReaderFB
//    Description: Trigger the barcode verifier and receive a "Barcode OK" signal, or nothing which indicates no read.
//    Created by: Ben Hess
//    Created Date: January 29th, 2020

// Setup timers for reading offset and scanning distance
IF positionOffset > 0 THEN
	positionOffsetDelay(PT := TO_TIME(MILLISECONDS_IN_SECOND / (TO_REAL(feedSpeed) / positionOffset)) + T#120MS);
ELSE
	positionOffsetDelay(PT := T#0S);
END_IF

IF distanceToScan > 0 THEN
	waitForReadTimer(PT := TO_TIME(MILLISECONDS_IN_SECOND / (TO_REAL(feedSpeed) / distanceToScan)));
ELSE
	waitForReadTimer(PT := T#0S);
END_IF

IF _reset OR NOT THIS^.OptionActive THEN
	//
	state := eBaseBCVStates.Idle;
	barcodeFault := FALSE;
END_IF

CASE state OF
	
	eBaseBCVStates.Idle:				// Wait for trigger
									triggerScannerOutput := FALSE;
									waitForReadTimer.IN := FALSE;
									positionOffsetDelay.IN := FALSE;
									
									xBusy := FALSE;
									IF _trigger THEN
										state := eBaseBCVStates.WaitForOffset;
										positionOffsetDelay.IN := TRUE;
										xBusy := TRUE;
										xDone := FALSE;
									END_IF
									
									_trigger := FALSE;
									
	eBaseBCVStates.WaitForOffset: 		// Wait for offset to trigger read
									IF positionOffsetDelay.Q THEN
										state := eBaseBCVStates.TriggerReader;
										positionOffsetDelay.IN := FALSE;
									END_IF
									
	eBaseBCVStates.TriggerReader:		// Trigger the reader and then move to waiting state for result
									triggerScannerOutput := TRUE;
									waitForReadTimer.IN := TRUE;
									state := eBaseBCVStates.WaitingForResult;
									
	
	eBaseBCVStates.WaitingForResult:	// Wait for delayToCheckReadStatus timer.  If it times out we did not get a good read
									IF readGoodInput THEN
										_goodRead := TRUE;
										_badread := FALSE;
										currentGoodReadCount := currentGoodReadCount + 1;
										currentBadReadCount := 0;
										xDone := TRUE;
										state := eBaseBCVStates.Idle;
									ELSIF waitForReadTimer.Q OR badReadInput THEN
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
										state := eBaseBCVStates.Idle;
									END_IF
	
	eBaseBCVStates.Resetting:			//
	
	
END_CASE

SUPER^();