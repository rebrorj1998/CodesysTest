(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CognexDM374 EXTENDS FB_BaseComponent
VAR_INPUT
	start: BOOL;
	result : BOOL;
	resultID : POINTER TO ARRAY[0..1] OF BYTE;
	triggerReady : BOOL;
	triggerDwell : REAL;
	triggerAck : BOOL;
	triggerID : POINTER TO ARRAY[0..1] OF BYTE;
	badReads : UDINT;
END_VAR
VAR_OUTPUT
	trigger : BOOL;
	triggerEnable : BOOL;
	barcodeFault : BOOL;
	triggerFeedbackFault : FB_Fault(name := '');
	goodReadCount : UDINT;
	badReadCount : UDINT;
END_VAR
VAR
	_resultID : CombineBytes;
	_triggerID : CombineBytes;
	_triggerIDBuffer : INT;
	triggerAckTimer : Standard.TON := (PT := T#1S);
	triggerTimer : Standard.TON;
	state : eCognexDM374States;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
// Scanner is set for "continous" so it'll scan the duration of triggerTimer or a good read, whatever comes first. 

// Flip Flop the LSB and MSB so the resultID integer is correct
_resultID.bytes[0] := resultID^[1];
_resultID.bytes[1] := resultID^[0];

// Flip Flop the LSB and MSB so the triggerID integer is correct
_triggerID.bytes[0] := triggerID^[1];
_triggerID.bytes[1] := triggerID^[0];

// If reset or not enabled move to the idle state to clear all variables
IF resetONS.Q OR NOT enable THEN
	state := eCognexDM374States.Idle;
END_IF

// If trigger is high and we dont see an ack bit, fault after debounce
triggerAckTimer(IN := trigger AND NOT triggerAck);
triggerFeedbackFault.faultTrigger := triggerAckTimer.Q;

// Controls the trigger duration
triggerTimer(PT := TO_TIME(triggerDwell * 1000));

// DM374 State Machine
CASE state OF
	eCognexDM374States.Idle:
		trigger := FALSE;
		triggerTimer.IN := FALSE;
		triggerAckTimer.IN := FALSE;
		barcodeFault := FALSE;
		IF start AND triggerReady THEN
			_triggerIDBuffer := _triggerID.i;
			state := eCognexDM374States.Trigger;
		END_IF
	
	eCognexDM374States.Trigger:
		trigger := TRUE;
		triggerTimer.IN := TRUE;
		state := eCognexDM374States.WaitForResults;
	
	eCognexDM374States.WaitForResults:
		IF triggerTimer.Q THEN
			trigger := FALSE;
			// Make sure the resultID matches the triggerID for accurate results
			IF _resultID.i = _triggerIDBuffer THEN
				triggerTimer.IN := FALSE;
				state := eCognexDM374States.Idle;
				IF NOT result THEN
					badReadCount := badReadCount + 1;
					goodReadCount := 0;
				ELSE
					badReadCount := 0;
					goodReadCount := goodReadCount +1;
				END_IF
				IF badReadCount >= badReads THEN
					barcodeFault := TRUE;
				END_IF
			END_IF
		END_IF
END_CASE

// Setting this tag enables EtherNet/IP triggering
triggerEnable := TRUE;