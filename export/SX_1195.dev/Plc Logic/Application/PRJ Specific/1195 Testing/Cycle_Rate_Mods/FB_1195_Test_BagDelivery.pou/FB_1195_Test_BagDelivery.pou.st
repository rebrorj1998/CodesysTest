(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_1195_Test_BagDelivery EXTENDS FB_BaseComponent IMPLEMENTS IBagDelivery
VAR_INPUT
	simulateIO : BOOL;
	dryCycleEnable : BOOL;
	bagPresent : BOOL;
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
	stateWatch : FB_StateRateTracking;
	//variables for the state timer
// 	stateTimer:TON;
// 	laststate: INT;
// 	count_index :INT :=0;
// 	clr:BOOL:=FALSE;
// 	speedTracking : ARRAY[0..20] OF ARRAY[0..20] OF TIME;
// 	speedTracking_mt : ARRAY[0..20] OF ARRAY[0..20] OF TIME:=[21([21(T#0S)])]; 
 	state_index : INT:=0;
END_VAR
VAR_OUTPUT
	reverseFault : FB_Fault(name := Standard.CONCAT(_prefix,'Reverse Fault'));
	bagFailedToSeparate : FB_Fault(name := Standard.CONCAT(_prefix,'Failed To Separate'));
	noBagOverEye : FB_Fault(name := Standard.CONCAT(_prefix,'No Bag Over Photoeye'));
	motorFault : FB_Fault(name := CONCAT(_prefix, 'Film Feed Motor Fault'));
	motorCommFault : FB_Fault(name := CONCAT(_prefix, 'Film Feed Motor Comm Fault'));
END_VAR
VAR
	_feedAtPrintSpeed : BOOL;
	_feedBagOut : BOOL;
	_feedToPrintOffset : BOOL;
	_reverseToSeparate : BOOL;
	_bagFeedDone : BOOL;
	_bagSeparated : BOOL;
	_readyForPrint : BOOL;
	_printerExtraFeedLength : REAL := 0.5;
	//state : INT;
	state : eBagDeliveryStates;
	//nextState : INT;
	nextState : eBagDeliveryStates;
	moveBagDeliveryTimeout : Standard.TON;
	MC_MoveBagDelivery : MC_MoveRelative;
	MC_HaltBagDelivery : MC_Halt;
	MC_ResetBagDelivery : MC_Reset;
	MC_PowerUpBagDelivery : MC_Power;
	remainingLength : REAL;
	bagReversedToPrintOffset : BOOL;
	bagEdgePhotoeyeSim : FB_SimulatedFeedbackPhysicalInput(name := 'Bag Edge Photoeye Sim');
	printingNow : BOOL;
	_resetTimer: Standard.TON := (PT := T#250MS);
END_VAR
VAR_IN_OUT
	bagDeliveryMotor : Axis_REF;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();

{region "Axis Setup"}
// Setup of Motion Commands for Bag Delivery motor axis
MC_MoveBagDelivery(Axis := bagDeliveryMotor);
MC_HaltBagDelivery(Axis := bagDeliveryMotor);
MC_ResetBagDelivery(Axis := bagDeliveryMotor);
MC_PowerUpBagDelivery(
	enable := F_EtherCatSlaveCommsRunning(state := AZD4A_KED.wState) AND NOT (state = eBagDeliveryStates.Resetting), 
	axis := bagDeliveryMotor
);
{endregion}
moveBagDeliveryTimeout();
// If reset of motors fails state machine must move on
_resetTimer(IN := state = eBagDeliveryStates.Resetting);
//moveBagDeliveryTimeout();
	 
IF _reset THEN
	state := eBagDeliveryStates.Reset;
	nextState := eBagDeliveryStates.Idle;
	ClearStatus();
	MC_ResetBagDelivery.Execute := FALSE;
	_reset := FALSE;
END_IF
stateWatch(state:= state, trackingEnable := TRUE,cntUp := BagFeedDone);
//code to add timer to track duration in states
// stateTimer(PT:=T#10000S);
// IF clr THEN
// 	speedTracking:=speedTracking_mt;
// 	clr:=FALSE;
// END_IF
// IF state  = laststate THEN
// 	stateTimer.IN := TRUE;
// ELSIF state  <> laststate THEN
// 	stateTimer.IN := FALSE;
// 	IF state =0 THEN
// 		count_index := count_index +1;
// 	END_IF
// 	laststate:=state;
// END_IF
// speedTracking[state_index][count_index] := stateTimer.ET;
// 
// IF count_index >=20 THEN
// 	count_index :=0;
// END_IF
//End modded code
_stateString := TO_STRING(state);
_ready := state = 0 AND bagDeliveryMotor.CommStatus AND NOT bagDeliveryMotor.Error;
IF bagDeliveryMotor.Error THEN
	motorFault.faultTrigger := TRUE;
ELSE 
	motorFault.faultTrigger := FALSE;
END_IF

IF NOT bagDeliveryMotor.CommStatus THEN
	motorCommFault.faultTrigger := TRUE;
ELSE
	motorCommFault.faultTrigger := FALSE;
END_IF

IF trapezoidalPercent <= 0 THEN
	trapezoidalPercent := 0.1;
END_IF
CASE state OF
	
	eBagDeliveryStates.Idle:		
			state_index := 0;
			MC_ResetBagDelivery.Execute := FALSE;
			moveBagDeliveryTimeout.IN := FALSE;
			// Idle
			IF _feedBagOut THEN
				state := eBagDeliveryStates.FeedBagOut;//10
				_feedBagOut := FALSE;
				ClearStatus();
			END_IF
			
			IF _feedToPrintOffset THEN
				state := eBagDeliveryStates.FeedToPrintOffset;//20;
				_feedToPrintOffset := FALSE;
				ClearStatus();
			END_IF
			
			IF _reverseToSeparate THEN
				_bagSeparated := FALSE;
				state := eBagDeliveryStates.FeedToPhotoEye;//50;
				_reverseToSeparate := FALSE;
				ClearStatus();
			END_IF
			
			IF _feedAtPrintSpeed THEN
				state := eBagDeliveryStates.FeedAtPrintSpeed;//40;
				_feedAtPrintSpeed := FALSE;
				ClearStatus();
			END_IF
			IF _makeReady THEN 
				IF (NOT bagPresent AND NOT HMIData.dryCycleEnable)THEN
					state:= eBagDeliveryStates.Cleanup;//100;
				END_IF
				_makeReady := FALSE;
			END_IF

	eBagDeliveryStates.FeedBagOut:		// Feed bag out state was 10
			state_index := 5;
			MC_MoveBagDelivery.Acceleration := AxisData.FilmFeedForwardMotionProfile.acceleration;
			MC_MoveBagDelivery.Deceleration := AxisData.FilmFeedForwardMotionProfile.deceleration;
			MC_MoveBagDelivery.Velocity := feedSpeed;
			MC_MoveBagDelivery.currentLimit := 100;
			MC_MoveBagDelivery.Distance := remainingLength;
			moveBagDeliveryTimeout.PT := MoveTimeoutCalc(remainingLength, feedSpeed, 2000);
			//moveBagDeliveryTimeout.IN := TRUE;
			MC_MoveBagDelivery.Execute := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Feeding Bag Out'));
			state := eBagDeliveryStates.WaitingForMoveCompletion;
			nextState := eBagDeliveryStates.FeedingBagOut;
			
	eBagDeliveryStates.FeedingBagOut:		// Set Bag Feed Done
			state_index := 6;
			_bagFeedDone := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Bag Feed Done'));
			state := eBagDeliveryStates.Idle;
			nextState := eBagDeliveryStates.Idle;
	
	eBagDeliveryStates.FeedToPrintOffset:		// Feed bag to print offset.  If already at print offset from reversing, continue
			state_index := 7;
			IF bagReversedToPrintOffset or printOffset = 0 THEN
				state := eBagDeliveryStates.FeedingToPrintOffset;
				nextState := eBagDeliveryStates.Idle;
				bagReversedToPrintOffset := FALSE;
			ELSE
				MC_MoveBagDelivery.Acceleration := AxisData.FilmFeedPrintOffsetMotionProfile.acceleration;
				MC_MoveBagDelivery.Deceleration := AxisData.FilmFeedPrintOffsetMotionProfile.deceleration;
				MC_MoveBagDelivery.Velocity := feedSpeed;
				MC_MoveBagDelivery.currentLimit := 100;
				MC_MoveBagDelivery.Distance := printOffset;
				remainingLength := remainingLength - printOffset;
				moveBagDeliveryTimeout.PT := MoveTimeoutCalc(printOffset, feedSpeed, 2000);
				//moveBagDeliveryTimeout.IN := TRUE;
				MC_MoveBagDelivery.Execute := TRUE;
				_logger.AddLogItem(CONCAT(_prefix, 'Feeding Bag to Print Offset'));
				state := eBagDeliveryStates.WaitingForMoveCompletion;
				nextState := eBagDeliveryStates.FeedingToPrintOffset;	
			END_IF
	
	eBagDeliveryStates.FeedingToPrintOffset: 	// Set Ready For Print
			state_index := 8;
			_readyForPrint := TRUE;
			state := eBagDeliveryStates.Idle;
			nextState := eBagDeliveryStates.Idle;	
	
	eBagDeliveryStates.FeedToPhotoEye: 	// Feed bag if not over photoeye
			state_index := 9;
			IF NOT bagPresent AND NOT dryCycleEnable THEN
				MC_MoveBagDelivery.Acceleration := MC_MoveBagDelivery.Deceleration := (reverseSpeed / trapezoidalPercent);
				MC_MoveBagDelivery.Velocity := reverseSpeed;
				MC_MoveBagDelivery.currentLimit := 100;
				MC_MoveBagDelivery.Distance := maxReverseSetpoint;
				moveBagDeliveryTimeout.PT := MoveTimeoutCalc(maxReverseSetpoint, reverseSpeed, 2000);
				//moveBagDeliveryTimeout.IN := TRUE;
				MC_MoveBagDelivery.Execute := TRUE;
				_logger.AddLogItem(CONCAT(_prefix, 'Feed to Photoeye'));
				state := eBagDeliveryStates.FeedingToPhotoEye;
			ELSE
				state := eBagDeliveryStates.ReverseToSeperate;
			END_IF
			
	eBagDeliveryStates.FeedingToPhotoEye: 	// If move completed then fault, otherwise stop at photoeye
			state_index := 10;
			IF MC_MoveBagDelivery.Done THEN
				MC_MoveBagDelivery.Execute := FALSE;
				noBagOverEye.Trigger();
				ClearStatus();
				state := eBagDeliveryStates.Cleanup;
				nextState := eBagDeliveryStates.Idle;
			END_IF
			
			IF MC_MoveBagDelivery.Error OR moveBagDeliveryTimeout.Q THEN
				reverseFault.Trigger();
				MC_MoveBagDelivery.Execute := FALSE;
				MC_HaltBagDelivery.Execute := TRUE;
				ClearStatus();
				nextState := eBagDeliveryStates.Idle;
				state := eBagDeliveryStates.Cleanup;
			END_IF
			
			IF bagPresent THEN
				MC_MoveBagDelivery.Execute := FALSE;
				MC_HaltBagDelivery.Execute := TRUE;
				bagEdgePhotoeyeSim.in := FALSE;
				state := eBagDeliveryStates.FeedToPhotoEyeDone;
				moveBagDeliveryTimeout.IN := FALSE;
				
			END_IF
		
	eBagDeliveryStates.FeedToPhotoEyeDone:		// Wait for bag to stop
			state_index := 11;
			IF MC_HaltBagDelivery.Done THEN
				MC_HaltBagDelivery.Execute := FALSE;
				state := eBagDeliveryStates.ReverseToSeperate;
			END_IF
	
	eBagDeliveryStates.ReverseToSeperate:		// Reverse to Separate
			state_index := 1;
			MC_MoveBagDelivery.Acceleration := MC_MoveBagDelivery.Deceleration := AxisData.FilmFeedReverseMotionProfile.acceleration;
			MC_MoveBagDelivery.Velocity := reverseSpeed;
			MC_MoveBagDelivery.currentLimit := 100;
			MC_MoveBagDelivery.Distance := maxReverseSetpoint * -1;
			moveBagDeliveryTimeout.PT := MoveTimeoutCalc(maxReverseSetpoint, reverseSpeed, 2000);
			//moveBagDeliveryTimeout.IN := TRUE;
			MC_MoveBagDelivery.Execute := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Reversing to Photoeye'));
			bagEdgePhotoeyeSim.in := TRUE;
			state := eBagDeliveryStates.ReversingToSeperate;
			//nextState := eBagDeliveryStates.ReversingToSeperate;
	
	eBagDeliveryStates.ReversingToSeperate:		// Stop bag once edge clears photoeye. If move command finishes that means the bag didn't separate 
			state_index := 2;
			IF MC_MoveBagDelivery.Done AND NOT dryCycleEnable THEN
				MC_MoveBagDelivery.Execute := FALSE;
				bagFailedToSeparate.Trigger();
				ClearStatus();
				state := eBagDeliveryStates.Cleanup;
				nextState := eBagDeliveryStates.Idle;
			END_IF
			
			IF MC_MoveBagDelivery.Done AND dryCycleEnable THEN
				MC_MoveBagDelivery.Execute := FALSE;
				MC_HaltBagDelivery.Execute := FALSE;
				bagEdgePhotoeyeSim.in := FALSE;
				state := eBagDeliveryStates.ReversingToSeperateDone;
			END_IF
			
			IF MC_MoveBagDelivery.Error OR moveBagDeliveryTimeout.Q THEN
				reverseFault.Trigger();
				MC_MoveBagDelivery.Execute := FALSE;
				MC_HaltBagDelivery.Execute := TRUE;
				ClearStatus();
				nextState := eBagDeliveryStates.ReversingToSeperateDone;
				state := eBagDeliveryStates.Cleanup;
			END_IF
			
			IF NOT bagPresent AND NOT dryCycleEnable THEN
				MC_MoveBagDelivery.Execute := FALSE;
				MC_HaltBagDelivery.Execute := TRUE;
				bagEdgePhotoeyeSim.in := FALSE;
				state := eBagDeliveryStates.ReversingToSeperateDone;
			END_IF
		
	eBagDeliveryStates.ReversingToSeperateDone: 	// Set Bag Reversed
			state_index := 3;
			IF MC_HaltBagDelivery.Done OR dryCycleEnable THEN
				MC_HaltBagDelivery.Execute := FALSE;
				remainingLength := bagLength - sealOffset + distanceFromSealBarToBagEdge;
				_bagSeparated := TRUE;
				state := eBagDeliveryStates.Idle;
				nextState := eBagDeliveryStates.Idle;
			END_IF
			
	eBagDeliveryStates.FeedAtPrintSpeed:		// Feed at Print Speed
			state_index := 12;
			MC_MoveBagDelivery.Acceleration := AxisData.FilmFeedPrintMotionProfile.acceleration;
			MC_MoveBagDelivery.Deceleration := AxisData.FilmFeedPrintMotionProfile.deceleration;
			MC_MoveBagDelivery.Velocity := printSpeed;
			MC_MoveBagDelivery.currentLimit := 100;
			MC_MoveBagDelivery.Distance := printLength + _printerExtraFeedLength;
			moveBagDeliveryTimeout.PT := MoveTimeoutCalc(distanceFromNipToBagEdge, reverseSpeed, 2000);
			//moveBagDeliveryTimeout.IN := TRUE;
			MC_MoveBagDelivery.Execute := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Feeding At Print Speed'));
			remainingLength := remainingLength - printLength - _printerExtraFeedLength;
			_feedBagOut := FALSE;
			printingNow := TRUE;
			state := eBagDeliveryStates.WaitingForMoveCompletion;
			nextState := eBagDeliveryStates.FeedBagOut;
	
	eBagDeliveryStates.Cleanup:	// Cleanup
			state_index := 5;
			MC_MoveBagDelivery.Execute := FALSE;
			MC_HaltBagDelivery.Execute := FALSE;
			moveBagDeliveryTimeout.IN := FALSE;
			bagEdgePhotoeyeSim.in := FALSE;
			state := nextState;				
			

	
	eBagDeliveryStates.WaitingForMoveCompletion: 	// Wait for Move to complete
			state_index := 4;
			IF MC_MoveBagDelivery.Error OR moveBagDeliveryTimeout.Q THEN
				MC_MoveBagDelivery.Execute := FALSE;
				MC_HaltBagDelivery.Execute := TRUE;
				moveBagDeliveryTimeout.IN := FALSE;
				ClearStatus();
				nextState := eBagDeliveryStates.Idle;
				state := eBagDeliveryStates.Cleanup;
			END_IF
			
			IF MC_MoveBagDelivery.Done THEN
				IF printingNow THEN
					printer.StopPrinting();
					IF printer.PrintDone OR dryCycleEnable THEN
						printingNow := FALSE;
						moveBagDeliveryTimeout.IN := FALSE;
						MC_MoveBagDelivery.Execute := FALSE;
						state := nextState;
					END_IF
				ELSE
					moveBagDeliveryTimeout.IN := FALSE;
					MC_MoveBagDelivery.Execute := FALSE;
					state := nextState;
				END_IF
			END_IF
			
	eBagDeliveryStates.MoveComplete:	// Set In Position and go back to idle
			state_index := 13;
			nextState := eBagDeliveryStates.Idle;
			state := eBagDeliveryStates.Cleanup;
			
	eBagDeliveryStates.Reset:		//Reset:
		state_index := 14;
		_feedAtPrintSpeed := FALSE;
		_feedBagOut := FALSE;
		_feedToPrintOffset := FALSE;
		_reverseToSeparate := FALSE;
		
		//_timeoutTimer.IN := FALSE;
		//jawTestModeActive := FALSE;
		
		MC_MoveBagDelivery.execute := FALSE;
		MC_HaltBagDelivery.execute := FALSE;
		MC_ResetBagDelivery.execute := TRUE;
		//MC_PowerUpBagDelivery.execute := FALSE;
				
		
		state := eBagDeliveryStates.Resetting;

	eBagDeliveryStates.Resetting:		//Resetting:
		state_index := 15;
		IF  _resetTimer.Q THEN
			MC_ResetBagDelivery.Execute := FALSE;	
			state := eBagDeliveryStates.ResetDone;
		END_IF
		
	eBagDeliveryStates.ResetDone:		//ResetDone:
		state_index := 16;
 		IF bagDeliveryMotor.operational THEN
 			state := eBagDeliveryStates.Cleanup;
 		END_IF

END_CASE
// CASE state OF
// 	
// 	0:		
// 			state_index := 0;
// 			MC_ResetBagDelivery.Execute := FALSE;
// 			// Idle
// 			IF _feedBagOut THEN
// 				state := 10;
// 				_feedBagOut := FALSE;
// 				ClearStatus();
// 			END_IF
// 			
// 			IF _feedToPrintOffset THEN
// 				state := 20;
// 				_feedToPrintOffset := FALSE;
// 				ClearStatus();
// 			END_IF
// 			
// 			IF _reverseToSeparate THEN
// 				_bagSeparated := FALSE;
// 				state := 50;
// 				_reverseToSeparate := FALSE;
// 				ClearStatus();
// 			END_IF
// 			
// 			IF _feedAtPrintSpeed THEN
// 				state := 40;
// 				_feedAtPrintSpeed := FALSE;
// 				ClearStatus();
// 			END_IF
// 			IF _makeReady THEN 
// 				IF (NOT bagPresent AND NOT HMIData.dryCycleEnable)THEN
// 					state:= 100;
// 				END_IF
// 				_makeReady := FALSE;
// 			END_IF
// 
// 	10:		// Feed bag out
// 			state_index := 5;
// 			MC_MoveBagDelivery.Acceleration := MC_MoveBagDelivery.Deceleration := (feedSpeed / trapezoidalPercent);
// 			MC_MoveBagDelivery.Velocity := feedSpeed;
// 			MC_MoveBagDelivery.currentLimit := 100;
// 			MC_MoveBagDelivery.Distance := remainingLength;
// 			moveBagDeliveryTimeout.PT := MoveTimeoutCalc(remainingLength, feedSpeed, 1000);
// 			moveBagDeliveryTimeout.IN := TRUE;
// 			MC_MoveBagDelivery.Execute := TRUE;
// 			_logger.AddLogItem(CONCAT(_prefix, 'Feeding Bag Out'));
// 			state := 101;
// 			nextState := 11;
// 			
// 	11:		// Set Bag Feed Done
// 			state_index := 6;
// 			_bagFeedDone := TRUE;
// 			_logger.AddLogItem(CONCAT(_prefix, 'Bag Feed Done'));
// 			state := 0;
// 			nextState := 0;
// 	
// 	20:		// Feed bag to print offset.  If already at print offset from reversing, continue
// 			state_index := 7;
// 			IF bagReversedToPrintOffset or printOffset = 0 THEN
// 				state := 21;
// 				nextState := 0;
// 				bagReversedToPrintOffset := FALSE;
// 			ELSE
// 				MC_MoveBagDelivery.Acceleration := MC_MoveBagDelivery.Deceleration := (feedSpeed / trapezoidalPercent);
// 				MC_MoveBagDelivery.Velocity := feedSpeed;
// 				MC_MoveBagDelivery.currentLimit := 100;
// 				MC_MoveBagDelivery.Distance := printOffset;
// 				remainingLength := remainingLength - printOffset;
// 				moveBagDeliveryTimeout.PT := MoveTimeoutCalc(printOffset, feedSpeed, 1000);
// 				moveBagDeliveryTimeout.IN := TRUE;
// 				MC_MoveBagDelivery.Execute := TRUE;
// 				_logger.AddLogItem(CONCAT(_prefix, 'Feeding Bag to Print Offset'));
// 				state := 101;
// 				nextState := 21;	
// 			END_IF
// 	
// 	21: 	// Set Ready For Print
// 			state_index := 8;
// 			_readyForPrint := TRUE;
// 			state := 0;
// 			nextState := 0;	
// 	
// 	50: 	// Feed bag if not over photoeye
// 			state_index := 9;
// 			IF NOT bagPresent AND NOT dryCycleEnable THEN
// 				MC_MoveBagDelivery.Acceleration := MC_MoveBagDelivery.Deceleration := (reverseSpeed / trapezoidalPercent);
// 				MC_MoveBagDelivery.Velocity := reverseSpeed;
// 				MC_MoveBagDelivery.currentLimit := 100;
// 				MC_MoveBagDelivery.Distance := maxReverseSetpoint;
// 				moveBagDeliveryTimeout.PT := MoveTimeoutCalc(maxReverseSetpoint, reverseSpeed, 1000);
// 				moveBagDeliveryTimeout.IN := TRUE;
// 				MC_MoveBagDelivery.Execute := TRUE;
// 				_logger.AddLogItem(CONCAT(_prefix, 'Feed to Photoeye'));
// 				state := 51;
// 			ELSE
// 				state := 30;
// 			END_IF
// 			
// 	51: 	// If move completed then fault, otherwise stop at photoeye
// 			state_index := 10;
// 			IF MC_MoveBagDelivery.Done THEN
// 				MC_MoveBagDelivery.Execute := FALSE;
// 				noBagOverEye.Trigger();
// 				ClearStatus();
// 				state := 100;
// 				nextState := 0;
// 			END_IF
// 			
// 			IF MC_MoveBagDelivery.Error OR moveBagDeliveryTimeout.Q THEN
// 				reverseFault.Trigger();
// 				MC_MoveBagDelivery.Execute := FALSE;
// 				MC_HaltBagDelivery.Execute := TRUE;
// 				ClearStatus();
// 				nextState := 0;
// 				state := 100;
// 			END_IF
// 			
// 			IF bagPresent THEN
// 				MC_MoveBagDelivery.Execute := FALSE;
// 				MC_HaltBagDelivery.Execute := TRUE;
// 				bagEdgePhotoeyeSim.in := FALSE;
// 				state := 52;
// 				
// 			END_IF
// 		
// 	52:		// Wait for bag to stop
// 			state_index := 11;
// 			IF MC_HaltBagDelivery.Done THEN
// 				MC_HaltBagDelivery.Execute := FALSE;
// 				state := 30;
// 			END_IF
// 	
// 	30:		// Reverse to Separate
// 			state_index := 1;
// 			MC_MoveBagDelivery.Acceleration := MC_MoveBagDelivery.Deceleration := (reverseSpeed / trapezoidalPercent);
// 			MC_MoveBagDelivery.Velocity := reverseSpeed;
// 			MC_MoveBagDelivery.currentLimit := 100;
// 			MC_MoveBagDelivery.Distance := maxReverseSetpoint * -1;
// 			moveBagDeliveryTimeout.PT := MoveTimeoutCalc(maxReverseSetpoint, reverseSpeed, 1000);
// 			moveBagDeliveryTimeout.IN := TRUE;
// 			MC_MoveBagDelivery.Execute := TRUE;
// 			_logger.AddLogItem(CONCAT(_prefix, 'Reversing to Photoeye'));
// 			bagEdgePhotoeyeSim.in := TRUE;
// 			state := 31;
// 			//nextState := 31;
// 	
// 	31:		// Stop bag once edge clears photoeye. If move command finishes that means the bag didn't separate 
// 			state_index := 2;
// 			IF MC_MoveBagDelivery.Done AND NOT dryCycleEnable THEN
// 				MC_MoveBagDelivery.Execute := FALSE;
// 				bagFailedToSeparate.Trigger();
// 				ClearStatus();
// 				state := 100;
// 				nextState := 0;
// 			END_IF
// 			
// 			IF MC_MoveBagDelivery.Done AND dryCycleEnable THEN
// 				MC_MoveBagDelivery.Execute := FALSE;
// 				MC_HaltBagDelivery.Execute := FALSE;
// 				bagEdgePhotoeyeSim.in := FALSE;
// 				state := 32;
// 			END_IF
// 			
// 			IF MC_MoveBagDelivery.Error OR moveBagDeliveryTimeout.Q THEN
// 				reverseFault.Trigger();
// 				MC_MoveBagDelivery.Execute := FALSE;
// 				MC_HaltBagDelivery.Execute := TRUE;
// 				ClearStatus();
// 				nextState := 32;
// 				state := 100;
// 			END_IF
// 			
// 			IF NOT bagPresent AND NOT dryCycleEnable THEN
// 				MC_MoveBagDelivery.Execute := FALSE;
// 				MC_HaltBagDelivery.Execute := TRUE;
// 				bagEdgePhotoeyeSim.in := FALSE;
// 				state := 32;
// 			END_IF
// 		
// 	32: 	// Set Bag Reversed
// 			state_index := 3;
// 			IF MC_HaltBagDelivery.Done OR dryCycleEnable THEN
// 				MC_HaltBagDelivery.Execute := FALSE;
// 				remainingLength := bagLength - sealOffset + distanceFromSealBarToBagEdge;
// 				_bagSeparated := TRUE;
// 				state := 0;
// 				nextState := 0;
// 			END_IF
// 			
// 	40:		// Feed at Print Speed
// 			state_index := 12;
// 			MC_MoveBagDelivery.Acceleration := MC_MoveBagDelivery.Deceleration := (printSpeed / trapezoidalPercent);
// 			MC_MoveBagDelivery.Velocity := printSpeed;
// 			MC_MoveBagDelivery.currentLimit := 100;
// 			MC_MoveBagDelivery.Distance := printLength + _printerExtraFeedLength;
// 			moveBagDeliveryTimeout.PT := MoveTimeoutCalc(distanceFromNipToBagEdge, reverseSpeed, 1000);
// 			moveBagDeliveryTimeout.IN := TRUE;
// 			MC_MoveBagDelivery.Execute := TRUE;
// 			_logger.AddLogItem(CONCAT(_prefix, 'Feeding At Print Speed'));
// 			remainingLength := remainingLength - printLength - _printerExtraFeedLength;
// 			_feedBagOut := FALSE;
// 			printingNow := TRUE;
// 			state := 101;
// 			nextState := 10;
// 	
// 	100:	// Cleanup
// 			state_index := 5;
// 			MC_MoveBagDelivery.Execute := FALSE;
// 			MC_HaltBagDelivery.Execute := FALSE;
// 			moveBagDeliveryTimeout.IN := FALSE;
// 			bagEdgePhotoeyeSim.in := FALSE;
// 			state := nextState;				
// 			
// 
// 	
// 	101: 	// Wait for Move to complete
// 			state_index := 4;
// 			IF MC_MoveBagDelivery.Error OR moveBagDeliveryTimeout.Q THEN
// 				MC_MoveBagDelivery.Execute := FALSE;
// 				MC_HaltBagDelivery.Execute := TRUE;
// 				moveBagDeliveryTimeout.IN := FALSE;
// 				ClearStatus();
// 				nextState := 0;
// 				state := 100;
// 			END_IF
// 			
// 			IF MC_MoveBagDelivery.Done THEN
// 				IF printingNow THEN
// 					printer.StopPrinting();
// 					IF printer.PrintDone THEN
// 						printingNow := FALSE;
// 						moveBagDeliveryTimeout.IN := FALSE;
// 						MC_MoveBagDelivery.Execute := FALSE;
// 						state := nextState;
// 					END_IF
// 				ELSE
// 					moveBagDeliveryTimeout.IN := FALSE;
// 					MC_MoveBagDelivery.Execute := FALSE;
// 					state := nextState;
// 				END_IF
// 			END_IF
// 			
// 	103:	// Set In Position and go back to idle
// 			state_index := 13;
// 			nextState := 0;
// 			state := 100;
// 			
// 	90:		//Reset:
// 		state_index := 14;
// 		_feedAtPrintSpeed := FALSE;
// 		_feedBagOut := FALSE;
// 		_feedToPrintOffset := FALSE;
// 		_reverseToSeparate := FALSE;
// 		
// 		//_timeoutTimer.IN := FALSE;
// 		//jawTestModeActive := FALSE;
// 		
// 		MC_MoveBagDelivery.execute := FALSE;
// 		MC_HaltBagDelivery.execute := FALSE;
// 		MC_ResetBagDelivery.execute := TRUE;
// 		//MC_PowerUpBagDelivery.execute := FALSE;
// 				
// 		
// 		state := 91;
// 
// 	91:		//Resetting:
// 		state_index := 15;
// 		IF  _resetTimer.Q THEN
// 			MC_ResetBagDelivery.Execute := FALSE;	
// 			state := 92;
// 		END_IF
// 		
// 	92:		//ResetDone:
// 		state_index := 16;
//  		IF bagDeliveryMotor.operational THEN
//  			state := 100;
//  		END_IF
// 
// END_CASE