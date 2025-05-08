(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CognexDM374 EXTENDS FB_BaseComponent
VAR_INPUT
	trigger : BOOL;
	triggerDwell : REAL;
	badScansAllowed : UDINT;
	inputScannerData : POINTER TO BYTE;
	outputScannerData : POINTER TO BYTE;
END_VAR
VAR_OUTPUT
	lastReadData : STRING[100];
	goodReadCount : UDINT;
	badReadCount : UDINT;
	barcodeFault : BOOL;
	triggerFeedbackFault : BOOL;
END_VAR
VAR
	_result : BOOL;
	_resultData : POINTER TO STRING[100];
	_resultDataLength : CombineBytes;
	_resultID : CombineBytes;
	_triggerID : CombineBytes;
	_triggerReady : BOOL;
	_triggerEnable : BOOL;
	_trigger : BOOL;
	_triggerONS : FB_ONS;
	_triggerAck : BOOL;
	_triggerIDBuffer : INT;
	_triggerAckTimer : Standard.TON := (PT := T#1S);
	_triggerTimer : Standard.TON;
	_state : eCognexDM374States;
	_resultAvailable: BOOL;
	_resultsAck: BOOL;
	test_me: BOOL;
	_bufferResultsEnable: BOOL;
	testme: BOOL;
	_checkResultsTimer : TON;
	triggerInterval: INT := 100;
	_goodReadSeen : BOOL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//
SUPER^();
// If reset or not enabled move to the idle state to clear all variables
IF resetONS.Q OR NOT enable THEN
	_state := eCognexDM374States.Idle;
END_IF
// Read data from barcode scanner
_triggerReady              := inputScannerData[0].0;
_triggerAck                := inputScannerData[0].1;
_triggerID.bytes[0]        := inputScannerData[6];
_triggerID.bytes[1]        := inputScannerData[7];
_resultID.bytes[0]         := inputScannerData[8];
_resultID.bytes[1]         := inputScannerData[9];
_result                    := inputScannerData[10].0;
_resultDataLength.bytes[0] := inputScannerData[13];
_resultDataLength.bytes[1] := inputScannerData[14];
_resultData                := ADR(inputScannerData[16]);
// Write data to barcode scanner
outputScannerData[0].0 := _triggerEnable;
outputScannerData[0].1 := _trigger;
outputScannerData[0].3 := _resultsAck;
// The resulting string of the last read barcode. Can possibly be two results in one string
//lastReadData := LEFT(_resultData^, _resultDataLength.i - 1); // taking this out as an exception was thrown on this operation for an as of yet unknown reason. Unused feature.
// Controls the trigger duration
_triggerTimer(PT := TO_TIME(triggerDwell * 1000));
_checkResultsTimer(PT:=TO_TIME(triggerInterval));
// If trigger is high and we dont see an ack bit, fault after debounce
_triggerAckTimer(IN := _trigger AND NOT _triggerAck, Q => triggerFeedbackFault);
// DM374 State Machine
CASE _state OF
	eCognexDM374States.Idle:
		_checkResultsTimer.IN:=FALSE;
		_trigger := FALSE;
		_triggerTimer.IN := FALSE;
		_triggerAckTimer.IN := FALSE;
		barcodeFault := FALSE;
		_triggerONS(CLK := trigger OR testme);
		_goodReadSeen := FALSE;
		IF _triggerONS.OSR AND _triggerReady THEN
			_triggerIDBuffer := _triggerID.i;
			_state := eCognexDM374States.Trigger;
		END_IF
		
	eCognexDM374States.Trigger:
		_trigger := TRUE;
		_triggerTimer.IN := TRUE;
		_checkResultsTimer.IN:=TRUE;
		//goodReadCount := 0;
		_state := eCognexDM374States.WaitForResults;
		
	eCognexDM374States.WaitForResults:
	//Dataman only transmits results after triggerring.  This area oscilates the trigger and evaluates results.
		IF _checkResultsTimer.IN THEN
			IF _checkResultsTimer.Q THEN
				//invert the trigger everytime the timer completes.
				_trigger:= NOT _trigger;
				_checkResultsTimer.IN:=FALSE;
				IF _trigger THEN
					//this is our on delay and we increment the trigger id buffer
					_triggerIDBuffer := _triggerID.i;
					_checkResultsTimer.PT:= TO_TIME(triggerInterval);
				ELSE
					//this is an off delay
					_checkResultsTimer.PT:= T#20MS;
				END_IF
			END_IF
		ELSIF NOT _checkResultsTimer.Q AND NOT _checkResultsTimer.IN THEN
			_checkResultsTimer.IN:=TRUE;
		END_IF
//Ensure that our results and trigger buffer match - means the currently evauluated trigger results are being processed
		IF _resultID.i = _triggerIDBuffer THEN
			//if we have a good read the _result will be high and we effectively abort.
			IF _result THEN
				_goodReadSeen := TRUE;
				_state := eCognexDM374States.FlushOutBuffer;
				badReadCount := 0;
				goodReadCount := goodReadCount +1;
			//if we haven't had a good read durring the trigger period we will fault.
			ELSIF _triggerTimer.Q THEN
				_triggerTimer.IN := FALSE;
				_state := eCognexDM374States.FlushOutBuffer;
				badReadCount := badReadCount + 1;
				goodReadCount := 0;
				IF badReadCount >= badScansAllowed THEN
					barcodeFault := TRUE;
				END_IF
			END_IF
		END_IF
		
	eCognexDM374States.FlushOutBuffer:
	// Flush out the remaining buffer in camera before continuing
		_state := eCognexDM374States.Idle;
		
		

END_CASE

// Setting this tag enables EtherNet/IP triggering
_triggerEnable := TRUE;