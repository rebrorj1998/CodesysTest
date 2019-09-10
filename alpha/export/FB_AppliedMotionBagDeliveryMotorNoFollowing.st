

FUNCTION_BLOCK FB_AppliedMotionBagDeliveryMotorNoFollowing EXTENDS FB_AppliedMotionStepServoEIPBase
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_moveDistance : BOOL;
	_moveDistanceONS : R_TRIG;
	_moveFinal : BOOL;
	_moveFinalONS : R_TRIG;
	_moveDone : BOOL;
	waitForMove : TON := (PT := T#30MS);
	manualFinalMovePB : BOOL;
	movedFinal : BOOL;
	moveDistanceState : AMP_EIP_MOVE_INITIAL_STATES;
	moveDistanceFinalState : AMP_EIP_MOVE_INITIAL_STATES;
END_VAR



METHOD Execute
VAR_INPUT
END_VAR

SUPER^.Execute();
waitForMove();
_moveDistanceONS(CLK := _moveDistance);
_moveFinalONS(CLK := _moveFinal);

CASE moveDistanceState OF
	AMP_EIP_MOVE_INITIAL_STATES.Idle :						
															IF _moveDistance THEN
																moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff;
															END_IF
															
	AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff :					sclCommand := 16#534F; //Output off
															parameter1 := 16#48B2;
															commands.SendHostCommand := TRUE;
															IF commandSuccessful THEN
																commandSuccessful := FALSE;
																moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOff;
															END_IF
															
	AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOff :		
															IF commandSuccessful THEN
																moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.MoveMotor;
															END_IF
																
	AMP_EIP_MOVE_INITIAL_STATES.MoveMotor: 					commandSuccessful := FALSE;
															sclCommand := 16#0;
															parameter1 := 16#0;
															commands.FeedToLength := TRUE;
															_moveDistance := FALSE;
															moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.WaitAfterMovingMotor;
															
															
	AMP_EIP_MOVE_INITIAL_STATES.WaitAfterMovingMotor: 		IF commandSuccessful THEN
																_moveDone := TRUE;
																moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.Idle;
															END_IF														
END_CASE

CASE moveDistanceFinalState OF
	AMP_EIP_MOVE_INITIAL_STATES.Idle :						IF _moveFinal THEN
																moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.MoveMotor;
															END_IF
	
	AMP_EIP_MOVE_INITIAL_STATES.MoveMotor: 					sclCommand := 16#0;
															parameter1 := 16#0;
															commandSuccessful := FALSE;	
															commands.FeedToLength := TRUE;
															moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.WaitAfterMovingMotor;
															
															
	AMP_EIP_MOVE_INITIAL_STATES.WaitAfterMovingMotor: 		IF commandSuccessful AND InPosition THEN	
																moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff;
															END_IF
														
	AMP_EIP_MOVE_INITIAL_STATES.SetOutputOff :					sclCommand := 16#534F; // Output on
															parameter1 := 16#4CB2;
															
															commandSuccessful := FALSE;
															commands.SendHostCommand := TRUE;
															_moveFinal := FALSE;
															moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOff;
															
															
	AMP_EIP_MOVE_INITIAL_STATES.WaitAfterSettingOutputOff :		
															IF commandSuccessful THEN
																_moveDone := TRUE;
																moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.Idle;
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

PROPERTY CommandAcknowledged : BOOL

METHOD SetRearMotorToTorqueMode
VAR_INPUT
END_VAR



METHOD SetRearMotorToEncoderFollowing
VAR_INPUT
END_VAR



METHOD StopViaProgram

// Load program segment 12 into buffer and execute.  This program contains nothing but a SM command.
// We must do it this way because the normal "stop command" opcode we have access to over modbus 
// also kills the program buffer which is bad.
SUPER^.Stop();

METHOD MoveDistanceFinal
VAR_INPUT
    distance : REAL;        //Distance to move in inches
    acceleration : INT;        //Acceleration in RPM/sec
    deceleration : INT;        //Deceleration in RPM/sec
    velocity : INT;            //Velocity in .25RPM
END_VAR

commandSuccessful := FALSE;
_moveDone := FALSE;
moveDistanceFinalState := AMP_EIP_MOVE_INITIAL_STATES.Idle;
distanceToMoveInSteps := REAL_TO_DINT((distance) * stepsPerInchSetpoint);
IF reversePolarity THEN
    distanceToMoveInSteps := distanceToMoveInSteps * -1;
END_IF

pointToPointAccelSetpoint := acceleration;
pointToPointDecelSetpoint := deceleration;
velocitySetpoint := velocity;

currentLimit := defaultCurrentSetpoint;
_moveFinal := TRUE;
//SUPER^.ExecuteStoredProgram(2);

METHOD MoveDistance
VAR_INPUT
    distance : REAL;        //Distance to move in inches
    acceleration : INT;        //Acceleration in RPM/sec
    deceleration : INT;        //Deceleration in RPM/sec
    velocity : INT;            //Velocity in .25RPM
END_VAR
commandSuccessful := FALSE;
_moveDone := FALSE;
moveDistanceState := AMP_EIP_MOVE_INITIAL_STATES.Idle;
distanceToMoveInSteps := REAL_TO_DINT((distance) * stepsPerInchSetpoint);

IF reversePolarity THEN
    distanceToMoveInSteps := distanceToMoveInSteps * -1;
END_IF

pointToPointAccelSetpoint := acceleration;
pointToPointDecelSetpoint := deceleration;
velocitySetpoint := velocity;

currentLimit := defaultCurrentSetpoint;
_moveDistance := TRUE;

//commands.feedToLength := TRUE;
//SUPER^.ExecuteStoredProgram(1);