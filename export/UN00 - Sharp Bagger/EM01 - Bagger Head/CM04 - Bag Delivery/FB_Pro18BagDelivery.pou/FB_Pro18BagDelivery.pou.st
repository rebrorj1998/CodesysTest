(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_Pro18BagDelivery EXTENDS FB_BaseComponent IMPLEMENTS IBagDelivery
VAR_INPUT
	simulateIO : BOOL;
	printer : IPrinter;
	bagLength : REAL := 24.0;
	feedSpeed : REAL := 30.0;
	reverseSpeed : REAL := 3.0;
	printSpeed : REAL := 6.0;
	printOffset : REAL := 4.5;
	printLength : REAL := 6.0;
	maxReverseSetpoint : REAL := 3.0;
	sealOffset : REAL := 1.5;
	distanceFromSealBarToBagEdge : REAL := 3;
	distanceFromNipToBagEdge : REAL := 1.25;
	trapezoidalPercent : REAL := 0.1;
END_VAR
VAR_OUTPUT
	bagDeliveryFailedToMove : FB_Fault(name := Standard.CONCAT(_prefix,'Failed To Move'));
	bagFailedToSeparate : FB_Fault(name := Standard.CONCAT(_prefix,'Failed To Separate'));
END_VAR
VAR
	_feedAtPrintSpeed : BOOL;
	_feedBagOut : BOOL;
	_feedToPrintOffset : BOOL;
	_reverseToSeparate : BOOL;
	_bagFeedDone : BOOL;
	_bagSeparated : BOOL;
	_readyForPrint : BOOL;
	state : INT;
	nextState : INT;
	moveBagDeliveryTimeout : Standard.TON;
	MC_MoveBagDelivery : MC_MoveRelative;
	MC_HaltBagDelivery : MC_Halt;
	MC_ResetBagDelivery : MC_Reset;
	remainingLength : REAL;
	bagReversedToPrintOffset : BOOL;
	bagEdgePhotoeyeSim : FB_SimulatedFeedbackPhysicalInput(name := 'Bag Edge Photoeye Sim');
END_VAR
VAR_IN_OUT
	bagDeliveryMotor : Axis_REF;
	bagPhotoeyeInput : FB_PhysicalDigitalInput;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();

{region "Axis Setup"}
// Setup of Motion Commands for Bag Delivery motor axis
MC_MoveBagDelivery(Axis := bagDeliveryMotor);
MC_HaltBagDelivery(Axis := bagDeliveryMotor);
MC_ResetBagDelivery(Axis := bagDeliveryMotor);
{endregion}
IF _reset THEN
	state := 100;
	nextState := 0;
	ClearStatus();
	IF bagDeliveryMotor.Error THEN
		MC_ResetBagDelivery.Execute := TRUE;
	END_IF
	_reset := FALSE;
END_IF

bagEdgePhotoeyeSim(
	in:= , 
	simFeedbackFault:= , 
	faultDelay:= , 
	minDelay:= 100, 
	maxDelay:= 1000, 
	Q=> , 
	fault=> , 
	inputToSimulate:= bagPhotoeyeInput);
//EnableSimulation(bagDeliveryMotor, simulateIO);
bagPhotoeyeInput.simulate := simulateIO;

IF trapezoidalPercent <= 0 THEN
	trapezoidalPercent := 0.1;
END_IF

CASE state OF
	0:		// Idle
			IF _feedBagOut THEN
				state := 10;
				_feedBagOut := FALSE;
				ClearStatus();
			END_IF
			
			IF _feedToPrintOffset THEN
				state := 20;
				_feedToPrintOffset := FALSE;
				ClearStatus();
			END_IF
			
			IF _reverseToSeparate THEN
				
				_bagSeparated := FALSE;
				state := 30;
				_reverseToSeparate := FALSE;
				ClearStatus();
			END_IF
			
			IF _feedAtPrintSpeed THEN
				state := 40;
				_feedAtPrintSpeed := FALSE;
				ClearStatus();
			END_IF
			
	1:		// Homing
			
			
			
	2:		// 
			
	
		
	

			
			
			
	4: 		// 
	
	5:		// 
	
	6:		// 
	
	7:		//

	10:		// Feed bag out
			MC_MoveBagDelivery.Acceleration := MC_MoveBagDelivery.Deceleration := (feedSpeed / trapezoidalPercent);
			MC_MoveBagDelivery.Velocity := feedSpeed;
			MC_MoveBagDelivery.Distance := remainingLength;
			moveBagDeliveryTimeout.PT := MoveTimeoutCalc(remainingLength, feedSpeed, 1000);
			moveBagDeliveryTimeout.IN := TRUE;
			MC_MoveBagDelivery.Execute := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Feeding Bag Out'));
			state := 101;
			nextState := 11;
			
	11:		// Set Bag Feed Done
			_bagFeedDone := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Bag Feed Done'));
			state := 0;
			nextState := 0;
	
	20:		// Feed bag to print offset.  If already at print offset from reversing, continue
			IF bagReversedToPrintOffset THEN
				state := 21;
				nextState := 0;
				bagReversedToPrintOffset := FALSE;
			ELSE
				MC_MoveBagDelivery.Acceleration := MC_MoveBagDelivery.Deceleration := (feedSpeed / trapezoidalPercent);
				MC_MoveBagDelivery.Velocity := feedSpeed;
				MC_MoveBagDelivery.Distance := printOffset;
				remainingLength := remainingLength - printOffset;
				moveBagDeliveryTimeout.PT := MoveTimeoutCalc(printOffset, feedSpeed, 1000);
				moveBagDeliveryTimeout.IN := TRUE;
				MC_MoveBagDelivery.Execute := TRUE;
				_logger.AddLogItem(CONCAT(_prefix, 'Feeding Bag to Print Offset'));
				state := 101;
				nextState := 21;	
			END_IF
			
	
	21: 	// Set Ready For Print
			_readyForPrint := TRUE;
			state := 0;
			nextState := 0;	
	
	30:		// Reverse to Separate
			MC_MoveBagDelivery.Acceleration := MC_MoveBagDelivery.Deceleration := (reverseSpeed / trapezoidalPercent);
			MC_MoveBagDelivery.Velocity := reverseSpeed;
			MC_MoveBagDelivery.Distance := maxReverseSetpoint;
			moveBagDeliveryTimeout.PT := MoveTimeoutCalc(maxReverseSetpoint, reverseSpeed, 1000);
			moveBagDeliveryTimeout.IN := TRUE;
			MC_MoveBagDelivery.Execute := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Reversing to Photoeye'));
			bagEdgePhotoeyeSim.in := TRUE;
			state := 31;
			//nextState := 31;
	
	31:		// Stop bag once edge clears photoeye. If move command finishes that means the bag didn't separate 
			IF MC_MoveBagDelivery.Done THEN
				bagFailedToSeparate.Trigger();
				ClearStatus();
				state := 100;
				nextState := 0;
			END_IF
			
			IF MC_MoveBagDelivery.Error OR moveBagDeliveryTimeout.Q THEN
				bagDeliveryFailedToMove.Trigger();
				MC_MoveBagDelivery.Execute := FALSE;
				MC_HaltBagDelivery.Execute := TRUE;
				ClearStatus();
				nextState := 0;
				state := 100;
			END_IF
			
			IF bagPhotoeyeInput.Active THEN
				MC_MoveBagDelivery.Execute := FALSE;
				MC_HaltBagDelivery.Execute := TRUE;
				bagEdgePhotoeyeSim.in := FALSE;
				state := 32;
			END_IF
		
	32: 	// Set Bag Reversed OR reverse further for zero print datum if needed
			IF MC_HaltBagDelivery.Done THEN
				MC_HaltBagDelivery.Execute := FALSE;
				IF NOT printer.OptionActive OR
				   printOffset >= distanceFromNipToBagEdge
				THEN
					remainingLength := bagLength + printOffset;
					_bagSeparated := TRUE;
					state := 0;
					nextState := 0;
				ELSE
					state := 33;
				END_IF
			END_IF
			
	
	33: 	// Reverse to Nip for zero print datum
			MC_MoveBagDelivery.Acceleration := MC_MoveBagDelivery.Deceleration := (reverseSpeed / trapezoidalPercent);
			MC_MoveBagDelivery.Velocity := reverseSpeed;
			MC_MoveBagDelivery.Distance := (distanceFromNipToBagEdge - printOffset) * -1;
			moveBagDeliveryTimeout.PT := MoveTimeoutCalc(distanceFromNipToBagEdge, reverseSpeed, 1000);
			moveBagDeliveryTimeout.IN := TRUE;
			MC_MoveBagDelivery.Execute := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Reversing to Nip'));
			remainingLength := remainingLength + distanceFromNipToBagEdge;
			state := 101;
			nextState := 34;

	34: 	_bagSeparated := TRUE;
			//_readyForPrint := TRUE;
			state := 0;
			nextState := 0;

	40:		// Feed at Print Speed
			MC_MoveBagDelivery.Acceleration := MC_MoveBagDelivery.Deceleration := (reverseSpeed / trapezoidalPercent);
			MC_MoveBagDelivery.Velocity := reverseSpeed;
			MC_MoveBagDelivery.Distance := printLength;
			moveBagDeliveryTimeout.PT := MoveTimeoutCalc(distanceFromNipToBagEdge, reverseSpeed, 1000);
			moveBagDeliveryTimeout.IN := TRUE;
			MC_MoveBagDelivery.Execute := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Feeding At Print Speed'));
			remainingLength := remainingLength - printLength;
			state := 101;
			nextState := 0;
	
	100:	// Cleanup
			MC_MoveBagDelivery.Execute := FALSE;
			MC_HaltBagDelivery.Execute := FALSE;
			moveBagDeliveryTimeout.IN := FALSE;
			bagEdgePhotoeyeSim.in := FALSE;
			state := nextState;
	
	101: 	// Wait for Move to complete
			IF MC_MoveBagDelivery.Error OR moveBagDeliveryTimeout.Q THEN
				bagDeliveryFailedToMove.Trigger();
				MC_MoveBagDelivery.Execute := FALSE;
				MC_HaltBagDelivery.Execute := TRUE;
				ClearStatus();
				nextState := 0;
				state := 100;
			END_IF
			
			IF MC_MoveBagDelivery.Done THEN
				moveBagDeliveryTimeout.IN := FALSE;
				MC_MoveBagDelivery.Execute := FALSE;
				state := nextState;
			END_IF
			
	
			
	103:	// Set In Position and go back to idle
			
			nextState := 0;
			state := 100;
			
END_CASE