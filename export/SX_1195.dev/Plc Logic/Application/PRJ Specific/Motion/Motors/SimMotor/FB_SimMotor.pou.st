(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_SimMotor EXTENDS Axis_REF
VAR_INPUT
	simFault : BOOL;
END_VAR
VAR_OUTPUT
END_VAR
VAR
	homingTimer : Standard.TON;
	movingTimer : Standard.TON;
	resetTimer : Standard.TON := (PT := T#500ms);
	state : INT;
	homingState : INT;
	moveAbsState : INT;
	moveRelState : INT;
	_reset : BOOL;
	distanceToMove : REAL;
	reverseMoveRequired : BOOL;
	
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_SimMotor()
//	Description: A simulated motor axis to test MC commands 
//				 
//	Created by: Ben Hess
//	Created Date: Tuesday, May 14th, 2019

homingTimer();
movingTimer();
resetTimer();
operational := PowerOn;
EnableState := DriveEnable;

IF AckError THEN
	_reset := TRUE;
END_IF

IF _reset THEN
	//Error := FALSE;
	resetTimer.IN := TRUE;
	isHomed := FALSE;
	_reset := FALSE;
END_IF

IF resetTimer.Q THEN
	Error := FALSE;
	resetTimer.IN := FALSE;
END_IF

IF simFault THEN 
	Error := TRUE;
	isHomed := FALSE;
	simFault := FALSE;
	TargetReached := FALSE;
END_IF

CASE state OF
	0:		// Idle
			IF StartHoming THEN
				state := 1;
			END_IF
			
			IF MoveAbs THEN
				TargetReached := FALSE;
				IF targetPosDist > ActPos THEN
					reverseMoveRequired := FALSE;
				ELSE
					reverseMoveRequired := TRUE;
				END_IF
				distanceToMove := ABS(ActPos - targetPosDist);
				MoveAbs := FALSE;
				AxisState := eAxisState.DiscreteMotion;
				state := 2;
			END_IF
			
			IF MoveRel THEN
				TargetReached := FALSE;
				distanceToMove := targetPosDist;
				state := 2;
			END_IF
		
	1:		// Homing
			homingTimer.PT := T#5S;
			homingTimer.IN := TRUE;
		
			IF homingTimer.Q THEN
				homingTimer.IN := FALSE;
				ActPos := 2.0;
				isHomed := TRUE;
				state := 100;
			END_IF
		
	2: 		// Moving to position
			movingTimer.PT := TO_TIME((distanceToMove * 1/ProfileVelocity) * 1000);
			movingTimer.IN := TRUE;
			IF reverseMoveRequired THEN
				ActPos := targetPosDist - ((TO_REAL(movingTimer.ET) * ProfileVelocity)  / 1000) + distanceToMove;
			ELSE
				ActPos := targetPosDist - ((TO_REAL(movingTimer.PT - movingTimer.ET) * ProfileVelocity)  / 1000);
			END_IF
			
			IF Halt THEN
				state := 100;
				AxisState := eAxisState.Standstill;
			END_IF
			IF movingTimer.Q THEN
				movingTimer.IN := FALSE;
				TargetReached := TRUE;
				AxisState := eAxisState.Standstill;
				state := 100;
			END_IF
			
	
	
	3:		// 
	
	
	100:	// Clear/Reset
			homingTimer.IN := FALSE;
			movingTimer.IN := FALSE;
			
			state := 0;
	
END_CASE


