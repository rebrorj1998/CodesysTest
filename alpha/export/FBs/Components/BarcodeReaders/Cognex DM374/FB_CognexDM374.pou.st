(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CognexDM374 EXTENDS FB_BaseComponent
VAR_INPUT
	start: BOOL;
	result : BOOL;
	resultAvailable : BOOL;
	triggerReady : BOOL;
	triggerDwell : REAL;
	triggerAck : BOOL;
END_VAR
VAR_OUTPUT
	trigger : BOOL;
	triggerEnable : BOOL;
	barcodeFault : BOOL;
	triggerFeedbackFault : FB_Fault(name := '');
END_VAR
VAR
	barcodeValid : BOOL;
	triggerAckDebounceDuration : TIME;
	triggerAckTimer : Standard.TON;
	triggerTimer : Standard.TON;
	state : eCognexDM374States;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

//
IF resetONS.Q OR NOT enable THEN
	state := eCognexDM374States.Idle;
END_IF

//
triggerAckTimer(PT := triggerAckDebounceDuration,
				IN := trigger AND NOT triggerAck);
triggerFeedbackFault.faultTrigger := triggerAckTimer.Q;

//
triggerTimer(PT := TO_TIME(triggerDwell * 1000));
CASE state OF
	eCognexDM374States.Idle:
		trigger := FALSE;
		triggerTimer.IN := FALSE;
		triggerAckTimer.IN := FALSE;
		barcodeFault := FALSE;
		IF start AND triggerReady THEN
			state := eCognexDM374States.Trigger;
		END_IF
	
	eCognexDM374States.Trigger:
		trigger := TRUE;
		triggerTimer.IN := TRUE;
		state := eCognexDM374States.WaitForResults;
	
	eCognexDM374States.WaitForResults:
		IF triggerTimer.Q THEN
			trigger := FALSE;
			IF resultAvailable THEN
				triggerTimer.IN := FALSE;
				IF NOT result THEN
					barcodeFault := TRUE;
					state := eCognexDM374States.Idle;
				END_IF
			END_IF
		END_IF
END_CASE

// Setting this tag enables EtherNet/IP triggering
triggerEnable := TRUE;