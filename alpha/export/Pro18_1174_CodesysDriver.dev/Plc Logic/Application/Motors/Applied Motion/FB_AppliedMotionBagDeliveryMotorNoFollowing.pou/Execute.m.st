(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Execute
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^.Execute();
waitForMove();
_moveDistanceONS(CLK := _moveDistance);
_moveFinalONS(CLK := _moveFinal);

CASE moveDistanceState OF
	BAG_DELIVERY_MOVE_STATES.Idle :						
															IF _moveDistance THEN
																moveDistanceState := BAG_DELIVERY_MOVE_STATES.SetToPointToPointMode;
															END_IF
															
	BAG_DELIVERY_MOVE_STATES.SetToPointToPointMode :					sclCommand := 16#534F; //Output off
															parameter1 := 16#48B2;
															commands.SendHostCommand := TRUE;
															IF commandSuccessful THEN
																commandSuccessful := FALSE;
																moveDistanceState := BAG_DELIVERY_MOVE_STATES.WaitAfterSettingOutputOff;
															END_IF
															
	BAG_DELIVERY_MOVE_STATES.WaitAfterSettingOutputOff :		
															IF commandSuccessful THEN
																moveDistanceState := BAG_DELIVERY_MOVE_STATES.MoveMotor;
															END_IF
																
	BAG_DELIVERY_MOVE_STATES.MoveMotor: 					commandSuccessful := FALSE;
															sclCommand := 16#0;
															parameter1 := 16#0;
															commands.FeedToLength := TRUE;
															_moveDistance := FALSE;
															moveDistanceState := BAG_DELIVERY_MOVE_STATES.WaitAfterMovingMotor;
															
															
	BAG_DELIVERY_MOVE_STATES.WaitAfterMovingMotor: 		IF commandSuccessful THEN
																_moveDone := TRUE;
																moveDistanceState := BAG_DELIVERY_MOVE_STATES.Idle;
															END_IF														
END_CASE

CASE moveDistanceFinalState OF
	BAG_DELIVERY_MOVE_STATES.Idle :						IF _moveFinal THEN
																moveDistanceFinalState := BAG_DELIVERY_MOVE_STATES.MoveMotor;
															END_IF
	
	BAG_DELIVERY_MOVE_STATES.MoveMotor: 					sclCommand := 16#0;
															parameter1 := 16#0;
															commandSuccessful := FALSE;	
															commands.FeedToLength := TRUE;
															moveDistanceFinalState := BAG_DELIVERY_MOVE_STATES.WaitAfterMovingMotor;
															
															
	BAG_DELIVERY_MOVE_STATES.WaitAfterMovingMotor: 		IF commandSuccessful AND InPosition THEN	
																moveDistanceFinalState := BAG_DELIVERY_MOVE_STATES.SetToPointToPointMode;
															END_IF
														
	BAG_DELIVERY_MOVE_STATES.SetToPointToPointMode :					sclCommand := 16#534F; // Output on
															parameter1 := 16#4CB2;
															
															commandSuccessful := FALSE;
															commands.SendHostCommand := TRUE;
															_moveFinal := FALSE;
															moveDistanceFinalState := BAG_DELIVERY_MOVE_STATES.WaitAfterSettingOutputOff;
															
															
	BAG_DELIVERY_MOVE_STATES.WaitAfterSettingOutputOff :		
															IF commandSuccessful THEN
																_moveDone := TRUE;
																moveDistanceFinalState := BAG_DELIVERY_MOVE_STATES.Idle;
															END_IF
																

END_CASE
(*
IF _moveFinal THEN	
	IF NOT movedFinal AND commandSuccessful THEN
		commandSuccessful := FALSE;
		commands.FeedToLength := TRUE;
		waitForMove.IN := TRUE;
		movedFinal := TRUE;
	END_IF
	
	IF commandSuccessful AND waitForMove.Q AND InPosition THEN
		sclCommand := 16#534F;
		parameter1 := 16#4CB2;
		commands.SendHostCommand := TRUE;
		_moveFinal := FALSE;
		waitForMove.IN := FALSE;
		movedFinal := FALSE;
	END_IF
END_IF
*)
IF manualFinalMovePB THEN
    MoveDistanceFinal(distance := distanceSetpointInches, acceleration := pointToPointAccelSetpoint, deceleration := pointToPointDecelSetpoint, velocity := velocitySetpoint);
    manualFinalMovePB := FALSE;
END_IF