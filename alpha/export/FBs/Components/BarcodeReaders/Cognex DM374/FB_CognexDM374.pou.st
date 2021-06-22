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
	barcodeFault : BOOL;
	goodReadCount : UDINT;
	badReadCount : UDINT;
	triggerFeedbackFault : FB_Fault(name := '');
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
//
_triggerReady       := inputsEIP[0].0;
_triggerAck         := inputsEIP[0].1;
_triggerID.bytes[0] := inputsEIP[6]; // Flip Flop the LSB and MSB so the triggerID integer is correct
_triggerID.bytes[1] := inputsEIP[7];
_resultID.bytes[0]  := inputsEIP[8]; // Flip Flop the LSB and MSB so the resultID integer is correct
_resultID.bytes[1]  := inputsEIP[9];
_result             := inputsEIP[10].0;
_resultDataLength.bytes[0] := inputsEIP[13];
_resultDataLength.bytes[1] := inputsEIP[14];
_resultData         := ADR(inputsEIP[16]);

//
outputsEIP[0].0 := _triggerEnable;
outputsEIP[0].1 := _trigger;

//
lastReadData := LEFT(_resultData^, _resultDataLength.i - 1);

// If reset or not enabled move to the idle state to clear all variables
IF resetONS.Q OR NOT enable THEN
	state := eCognexDM374States.Idle;
END_IF

// If trigger is high and we dont see an ack bit, fault after debounce
triggerAckTimer(IN := _trigger AND NOT _triggerAck);
triggerFeedbackFault.faultTrigger := triggerAckTimer.Q;

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
					badReadCount := badReadCount + 1;
					goodReadCount := 0;
				ELSE
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