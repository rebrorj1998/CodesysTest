(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CognexDM374 EXTENDS FB_BaseComponent
VAR_INPUT
	triggerInput : BOOL;
	triggerDwell : REAL;
	badReadFaultSetting : UDINT;
	inputsEIP : POINTER TO BYTE;
	outputsEIP : POINTER TO BYTE;
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
	_triggerAck : BOOL;
	_triggerIDBuffer : INT;
	triggerAckTimer : Standard.TON := (PT := T#1S);
	triggerTimer : Standard.TON;
	state : eCognexDM374States;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

// Read data from barcode scanner
_triggerReady := inputsEIP[0].0;
_triggerAck := inputsEIP[0].1;
_triggerID.bytes[0] := inputsEIP[6];
_triggerID.bytes[1] := inputsEIP[7];
_resultID.bytes[0] := inputsEIP[8];
_resultID.bytes[1] := inputsEIP[9];
_result := inputsEIP[10].0;
_resultDataLength.bytes[0] := inputsEIP[13];
_resultDataLength.bytes[1] := inputsEIP[14];
_resultData := ADR(inputsEIP[16]);

// Write data to barcode scanner
outputsEIP[0].0 := _triggerEnable;
outputsEIP[0].1 := _trigger;

// The resulting string of the last read barcode. Can possibly be two results in one string
lastReadData := LEFT(_resultData^, _resultDataLength.i - 1);

// If reset or not enabled move to the idle state to clear all variables
IF resetONS.Q OR NOT enable THEN
	state := eCognexDM374States.Idle;
END_IF

// If trigger is high and we dont see an ack bit, fault after debounce
triggerAckTimer(IN := _trigger AND NOT _triggerAck);
triggerFeedbackFault := triggerAckTimer.Q;

// Controls the trigger duration
triggerTimer(PT := TO_TIME(triggerDwell * 1000));

// DM374 State Machine
CASE state OF
	eCognexDM374States.Idle:
		_trigger := FALSE;
		triggerTimer.IN := FALSE;
		triggerAckTimer.IN := FALSE;
		barcodeFault := FALSE;
		IF triggerInput AND _triggerReady THEN
			_triggerIDBuffer := _triggerID.i;
			state := eCognexDM374States.Trigger;
		END_IF
	
	eCognexDM374States.Trigger:
		_trigger := TRUE;
		triggerTimer.IN := TRUE;
		state := eCognexDM374States.WaitForResults;
	
	eCognexDM374States.WaitForResults:
		IF triggerTimer.Q THEN
			_trigger := FALSE;
			// Make sure the resultID matches the triggerID for accurate results
			IF _resultID.i = _triggerIDBuffer THEN
				triggerTimer.IN := FALSE;
				state := eCognexDM374States.Idle;
				IF NOT _result THEN
					// Incremenet bad read count
					badReadCount := badReadCount + 1;
					goodReadCount := 0;
				ELSE
					// Increment good read count
					badReadCount := 0;
					goodReadCount := goodReadCount +1;
				END_IF
				IF badReadCount >= badReadFaultSetting THEN
					barcodeFault := TRUE;
				END_IF
			END_IF
		END_IF
END_CASE

// Setting this tag enables EtherNet/IP triggering
_triggerEnable := TRUE;