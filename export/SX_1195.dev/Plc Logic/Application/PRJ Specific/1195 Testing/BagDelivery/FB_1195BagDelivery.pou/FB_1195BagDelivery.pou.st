(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_1195BagDelivery EXTENDS FB_BaseComponent IMPLEMENTS IBagDelivery
VAR_INPUT
	simulateIO : BOOL;
	bagPresent : BOOL;
	dryCycle : BOOL;
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
	reverseFault : FB_Fault(name := Standard.CONCAT(_prefix,'Reverse Fault'));
	bagFailedToSeparate : FB_Fault(name := Standard.CONCAT(_prefix,'Failed To Separate'));
	noBagOverEye : FB_Fault(name := Standard.CONCAT(_prefix,'No Bag Over Photoeye'));
	motorFault : FB_Fault(name := CONCAT(_prefix, 'Film Feed Motor Fault'));
	motorCommFault : FB_Fault(name := CONCAT(_prefix, 'Film Feed Motor Comm Fault'));
END_VAR
VAR
	
	_bagFeedDone : BOOL;
	_bagSeparated : BOOL;
	_readyForPrint : BOOL;
	state : eBagDeliveryStates;
	moveBagDeliveryTimeout : Standard.TON;
	_resetTimer : TON := (PT := T#2S);
	MC_BagDeliveryRelativeMove : MC_MoveRelative;
	MC_BagDeliveryHalt : MC_Halt;
	MC_ResetBagDelivery : MC_Reset;
	MC_PowerBagDelivery  : MC_Power;
	remainingLength : REAL;
	bagEdgePhotoeyeSim : FB_SimulatedFeedbackPhysicalInput(name := 'Bag Edge Photoeye Sim');
	printingNow : BOOL;
END_VAR
VAR_IN_OUT
	bagDeliveryMotor : Axis_REF;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();
{region "Axis Setup"}
// Setup of Motion Commands for Bag Delivery motor axis
MC_BagDeliveryRelativeMove(Axis := bagDeliveryMotor);
MC_BagDeliveryHalt(Axis := bagDeliveryMotor);
MC_ResetBagDelivery(Axis := bagDeliveryMotor);
MC_PowerBagDelivery(Axis := bagDeliveryMotor, enable :=  F_EtherCatSlaveCommsRunning(state := AZD4A_KED.wState) AND NOT (state = eBagDeliveryStates.Resetting));
{endregion}
	 

	 
// IF _resetONS.Q THEN
// 	ClearStatus();
// 	state := eBagDeliveryStates.Cleanup;
// 	IF bagDeliveryMotor.Error OR NOT bagDeliveryMotor.CommStatus THEN
// 		MC_ResetBagDelivery.Execute := TRUE;
// 	END_IF
// END_IF

IF bagDeliveryMotor.Error THEN
	motorFault.faultTrigger := TRUE;
ELSE 
	motorFault.faultTrigger := FALSE;
END_IF

// IF NOT bagDeliveryMotor.CommStatus THEN
// 	motorCommFault.faultTrigger := TRUE;
// ELSE
// 	motorCommFault.faultTrigger := FALSE;
// END_IF

IF trapezoidalPercent <= 0 THEN
	trapezoidalPercent := 0.1;
END_IF

_resetTimer(IN := state = eBagDeliveryStates.Resetting);

CASE state OF
	eBagDeliveryStates.Idle:		
		_ready := NOT motorCommFault.active 
		AND NOT reverseFault.active
		AND NOT noBagOverEye.active
		AND NOT motorFault.active
        AND NOT bagFailedToSeparate.active; 

	eBagDeliveryStates.FeedBagOut:		
		RelativeMove(distance := remainingLength,
					 velocity := feedSpeed,
					  timeOut := MoveTimeoutCalc(remainingLength, feedSpeed, 1000),
				  description := 'Feed Bag Out',
                        state := eBagDeliveryStates.FeedingBagOut);
						
	eBagDeliveryStates.FeedToPrintOffset:		
		RelativeMove(distance := printOffset,
					 velocity := feedSpeed,
					  timeOut := MoveTimeoutCalc(remainingLength, feedSpeed, 1000),
				  description := 'Feed Bag to Print Offset',
                        state := eBagDeliveryStates.FeedingToPrintOffset);
		remainingLength := remainingLength - printOffset;

	eBagDeliveryStates.FeedAtPrintSpeed:
		RelativeMove(distance := printLength,
					 velocity := printSpeed,
					  timeOut := MoveTimeoutCalc(printLength, printSpeed, 1000),
				  description := 'Feed At Print Speed',
                        state := eBagDeliveryStates.FeedingAtPrintSpeed);
		remainingLength := remainingLength - printLength;
		printingNow := TRUE;

	eBagDeliveryStates.FeedingBagOut,
	eBagDeliveryStates.FeedingToPrintOffset,
	eBagDeliveryStates.FeedingAtPrintSpeed:
		// Wait for Move to complete or fault
		IF MC_BagDeliveryRelativeMove.Error OR moveBagDeliveryTimeout.Q THEN
			MC_BagDeliveryHalt.Execute := TRUE;
			IF MC_BagDeliveryHalt.Done THEN
				state := eBagDeliveryStates.Cleanup;
			END_IF
		END_IF

		IF MC_BagDeliveryRelativeMove.Done THEN
			IF state = eBagDeliveryStates.FeedingBagOut THEN
				_bagFeedDone := TRUE;
			END_IF
			IF state = eBagDeliveryStates.FeedingToPrintOffset THEN
				_readyForPrint := TRUE;
			END_IF
			IF printingNow THEN
				printer.StopPrinting();
				IF printer.PrintDone THEN
					printingNow := FALSE;
					state := eBagDeliveryStates.Cleanup;
				END_IF
			ELSE
				state := eBagDeliveryStates.Cleanup;
			END_IF
		END_IF		
	
	eBagDeliveryStates.FeedToPhotoEye: 	
		// Feed bag if not over photoeye
		RelativeMove(distance := maxReverseSetpoint,
					 velocity := reverseSpeed,
					  timeOut := MoveTimeoutCalc(maxReverseSetpoint, reverseSpeed, 1000),
				  description := 'Feeding to Photoeye',
						state := eBagDeliveryStates.FeedingToPhotoEye);
		
			
		eBagDeliveryStates.FeedingToPhotoEye:
		// If move completed, fault
		IF MC_BagDeliveryRelativeMove.Done THEN
			noBagOverEye.Trigger();
			state := eBagDeliveryStates.Cleanup;
		END_IF
								
		IF MC_BagDeliveryRelativeMove.Error OR moveBagDeliveryTimeout.Q THEN
			MC_BagDeliveryHalt.Execute := TRUE;
			IF MC_BagDeliveryHalt.Done THEN
				state := eBagDeliveryStates.Cleanup;
			END_IF
			noBagOverEye.Trigger();
		END_IF
								
		IF bagPresent THEN
			MC_BagDeliveryHalt.Execute := TRUE;
			IF MC_BagDeliveryHalt.Done THEN
				state := eBagDeliveryStates.Cleanup;
			END_IF
		END_IF
			
	eBagDeliveryStates.ReverseToSeperate:
		RelativeMove(distance := maxReverseSetpoint * -1,
				     velocity := reverseSpeed,
					  timeOut := MoveTimeoutCalc(maxReverseSetpoint, reverseSpeed, 1000),
				  description := 'Reverse to Photoeye',
					    state := eBagDeliveryStates.ReversingToSeperate);
	
	eBagDeliveryStates.ReversingToSeperate:
		// Wait for Move to complete or fault
		IF MC_BagDeliveryRelativeMove.Done THEN
			IF dryCycle THEN
				_bagSeparated := TRUE;
				remainingLength := bagLength - sealOffset + distanceFromSealBarToBagEdge;
			ELSE
				bagFailedToSeparate.Trigger(); 
			END_IF
			state := eBagDeliveryStates.Cleanup;
		END_IF				
										
		IF MC_BagDeliveryRelativeMove.Error OR moveBagDeliveryTimeout.Q THEN
			MC_BagDeliveryHalt.Execute := TRUE;
			IF MC_BagDeliveryHalt.Done THEN
				state := eBagDeliveryStates.Cleanup;
			END_IF
			reverseFault.Trigger();
		END_IF
										
		IF NOT bagPresent AND NOT dryCycle THEN
			MC_BagDeliveryHalt.Execute := TRUE;
			IF MC_BagDeliveryHalt.Done THEN
				_bagSeparated := TRUE;
				state := eBagDeliveryStates.Cleanup;
				remainingLength := bagLength - sealOffset + distanceFromSealBarToBagEdge;
			END_IF
		END_IF
	
	eBagDeliveryStates.Cleanup:	// Cleanup
		MC_BagDeliveryRelativeMove.Execute := FALSE;
		MC_BagDeliveryHalt.Execute := FALSE;
		moveBagDeliveryTimeout.IN := FALSE;
		state := eBagDeliveryStates.Idle;
		
	eBagDeliveryStates.Reset:	
		MC_ResetBagDelivery.execute := TRUE;
		state := eBagDeliveryStates.Resetting;
	
	eBagDeliveryStates.Resetting:	
		IF _resetTimer.Q THEN
			MC_ResetBagDelivery.execute := FALSE;
			state := eBagDeliveryStates.ResetDone;
		END_IF
	
	eBagDeliveryStates.ResetDone:	
		IF bagDeliveryMotor.operational THEN
			state := eBagDeliveryStates.Cleanup;
		END_IF
		
	
END_CASE