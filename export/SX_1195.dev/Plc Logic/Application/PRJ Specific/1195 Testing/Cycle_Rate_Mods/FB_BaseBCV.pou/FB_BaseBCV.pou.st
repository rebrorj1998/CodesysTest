(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_BaseBCV EXTENDS FB_BaseComponent IMPLEMENTS IBarcodeVerifier
VAR_INPUT
	feedSpeed : UDINT;
	positionOffset : REAL;
	distanceToScan : REAL;
	readGoodInput : BOOL;
	badReadInput : BOOL;
	badReadFaultCountSetting : UDINT;
	dryCycleEnable : BOOL;
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
	_triggerImmediate : BOOL;
	state : eBaseBCVStates;
	waitForReadTimer : Standard.TON := (PT := T#2S);
	positionOffsetDelay : Standard.TON;
	
				//variables for the state timer
	stateTimer:TON;
	laststate: INT;
	count_index :INT :=0;
	clr:BOOL:=FALSE;
	speedTracking : ARRAY[0..20] OF ARRAY[0..20] OF TIME;
	speedTracking_mt : ARRAY[0..20] OF ARRAY[0..20] OF TIME:=[21([21(T#0S)])]; 
	state_index : INT:=0;
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

// IF distanceToScan > 0 THEN
// 	waitForReadTimer(PT := TO_TIME(MILLISECONDS_IN_SECOND / (TO_REAL(feedSpeed) / distanceToScan)));
// ELSE
// 	waitForReadTimer(PT := T#0S);
// END_IF

IF _reset OR NOT THIS^.OptionActive THEN
	//
	_reset := FALSE;
	IF barcodeFault THEN
		currentBadReadCount := 0;
	END_IF
	state := eBaseBCVStates.Idle;
	barcodeFault := FALSE;
END_IF
//code to add timer to track duration in states
stateTimer(PT:=T#10000S);
IF clr THEN
	speedTracking:=speedTracking_mt;
	clr:=FALSE;
END_IF
IF state  = laststate THEN
	stateTimer.IN := TRUE;
ELSIF state  <> laststate THEN
	stateTimer.IN := FALSE;
	IF state =0 THEN
		count_index := count_index +1;
	END_IF
	laststate:=state;
END_IF
speedTracking[state_index][count_index] := stateTimer.ET;

IF count_index >=20 THEN
	count_index :=0;
END_IF
//End modded code
_ready := state = eBaseBCVStates.Idle;

waitForReadTimer();
_stateString := TO_STRING(state);
CASE state OF
	
	eBaseBCVStates.Idle:				// Wait for trigger
									state_index:= 0;
									triggerScannerOutput := FALSE;
									waitForReadTimer.IN := FALSE;
									positionOffsetDelay.IN := FALSE;
									
									xBusy := FALSE;
									IF _trigger THEN
										state := eBaseBCVStates.WaitForOffset;
										positionOffsetDelay.IN := TRUE;
										xBusy := TRUE;
										xDone := FALSE;
										_goodRead := FALSE;
										_badread := FALSE;
									END_IF
									
									IF _triggerImmediate THEN
										state := eBaseBCVStates.TriggerReader;
										xBusy := TRUE;
										xDone := FALSE;
										_goodRead := FALSE;
										_badread := FALSE;
									END_IF
									
									_trigger := FALSE;
									_triggerImmediate := FALSE;
									
	eBaseBCVStates.WaitForOffset: 		// Wait for offset to trigger read
									state_index:= 1;
									IF positionOffsetDelay.Q THEN
										state := eBaseBCVStates.TriggerReader;
										positionOffsetDelay.IN := FALSE;
									END_IF
									
	eBaseBCVStates.TriggerReader:		// Trigger the reader and then move to waiting state for result
									state_index:= 2;
									triggerScannerOutput := TRUE;
									
									state := eBaseBCVStates.WaitingForResult;
									
	
	eBaseBCVStates.WaitingForResult:	// Wait for delayToCheckReadStatus timer.  If it times out we did not get a good read
									state_index:= 3;
									waitForReadTimer.IN := TRUE;
									IF readGoodInput OR dryCycleEnable THEN
										_goodRead := TRUE;
										_badread := FALSE;
										currentGoodReadCount := currentGoodReadCount + 1;
										currentBadReadCount := 0;
										waitForReadTimer.IN := FALSE;
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
										waitForReadTimer.IN := FALSE;
										xDone := TRUE;
										state := eBaseBCVStates.Idle;
									END_IF
	
	eBaseBCVStates.Resetting:	
			state_index:= 4;		//
	
	
END_CASE

SUPER^();