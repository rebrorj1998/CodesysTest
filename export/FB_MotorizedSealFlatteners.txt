

FUNCTION_BLOCK FB_MotorizedSealFlatteners EXTENDS FB_BaseComponent IMPLEMENTS ISealFlatteners, IHomable
VAR_INPUT
	verticalAxis : IUpDown;
	
	clearanceDwellSetting : REAL;
	bagWidth : REAL;						// Bag width setting; will determine all MSF positions
	horizVelo : REAL := 10;
	horizAccel : REAL := 100;
	horizDecel : REAL := 100;
	bagHoldingCurrent : REAL := 0.8;
	sealCurrentAddition : REAL := 0.3;
	homeTimeoutSetting : TIME := T#20S;		// Timeout for homing attempt
	maximumPosition : REAL := 18.5;
	miniumumPosition : REAL := 7.25;
	clearanceOffset : REAL := 1.0;
END_VAR
VAR_OUTPUT
	msfHorizActualPosition : REAL;
	horizontalFailedToMove : FB_Fault(name := CONCAT(_prefix, 'Horizontal Axis Failed to Move'));
	horizontalFailedToHome : FB_Fault(name := CONCAT(_prefix, 'Horizontal Axis Failed to Home'));
	motorFault : FB_Fault(name := CONCAT(_prefix, 'Motor Fault'));
END_VAR
VAR
	MC_MoveMSFHorizTorqueLimited : Sharp_Motion.MC_MoveAbsoluteTorqueLimited;
	MC_MoveMSFHoriz : Sharp_Motion.MC_MoveAbsolute;
	MC_HomeMSFHoriz : Sharp_Motion.MC_Home;
	MC_HaltMSFHoriz : Sharp_Motion.MC_Halt;
	MC_ResetMSFHoriz : Sharp_Motion.MC_Reset;
	
	horizontalAxisInterface : Sharp_Motion.IAxisRef;
	state : INT;
	_inPosition : BOOL;
	_bagIsOpen : BOOL;
	_toBagFeed : BOOL;
	_toSeal : BOOL;
	_homeNow : BOOL;
	homeTimeout : Standard.TON;
	moveMSFHorizTimeout : Standard.TON;
	clearanceDwellTimer : Standard.TON;
	nextState : INT := 0;					// State to move to after confirmation of physical move
	testInterface : IHomable;
	testBool : BOOL;
END_VAR
VAR_IN_OUT
	horizontalAxis : Sharp_Motion.Axis_REF;
	
END_VAR

{region "Axis Setup"}
// Setup of Motion Commands for MSF Horizonal motor axis
MC_MoveMSFHorizTorqueLimited(Axis := horizontalAxis);
MC_MoveMSFHoriz(Axis := horizontalAxis);
MC_HomeMSFHoriz(Axis := horizontalAxis);
MC_HaltMSFHoriz(Axis := horizontalAxis);
MC_ResetMSFHoriz(Axis := horizontalAxis);  
{endregion}
horizontalAxisInterface := horizontalAxis;
{region "Timers"}
// If homing not complete within reasonable time, error out
homeTimeout(PT := homeTimeoutSetting);
// If flatteners don't reach setpoint in reasonable time, error out
moveMSFHorizTimeout();
	 
clearanceDwellTimer(PT := TO_TIME(clearanceDwellSetting * 1000));
{endregion}

msfHorizActualPosition := horizontalAxis.ActPos;

IF _reset THEN
	state := 100;
	nextState := 0;
	IF horizontalAxis.Error THEN
		MC_ResetMSFHoriz.Execute := TRUE;
	END_IF
	_reset := FALSE;
END_IF



IF __QUERYINTERFACE(horizontalAxisInterface, testInterface) THEN
	testBool := TRUE;
END_IF
 
CASE state OF
	0:		// Idle
			MC_ResetMSFHoriz.Execute := FALSE;
			IF horizontalAxis.HomingDone
				AND NOT horizontalFailedToMove.Active
				AND NOT motorFault.Active
			THEN
				_ready := TRUE;
			ELSE
				_ready := FALSE;
			END_IF
			
			IF _bagIsOpen THEN
				state := 10;
				_inPosition := FALSE;
				_bagIsOpen := FALSE;
			END_IF
			
			IF _toBagFeed THEN
				state := 20;
				_inPosition := FALSE;
				_toBagFeed := FALSE;
			END_IF
			
			IF _toSeal THEN
				state := 30;
				_inPosition := FALSE;
				_toSeal := FALSE;
			END_IF
			
			IF _homeNow THEN
				_inPosition := FALSE;
				IF NOT horizontalAxis.HomingDone THEN
					MC_HomeMSFHoriz.Execute := TRUE;
					state := 1;
				END_IF
				_homeNow := FALSE;
			END_IF
			
	1:		// Homing
			homeTimeout.IN := TRUE;
			verticalAxis.MoveUp();
			IF homeTimeout.Q 
				OR MC_HomeMSFHoriz.Error 
				OR UN00_Globals.simFaults.msfHorizontalFailedToHome
			THEN
				horizontalFailedToHome.Trigger();
				state := 100;
			END_IF
			IF MC_HomeMSFHoriz.Done THEN
				state := 100;
			END_IF
			
			
	2:		// 
			
	
		
	

			
			
			
	4: 		// 
	
	5:		// 
	
	6:		// 
	
	7:		//

	10:		// Move FROM bag feeding position TO bag holding because Bag Is Open
			// 1st step: Move In
			
			verticalAxis.MoveDown();
			MC_MoveMSFHoriz.Velocity := horizVelo;
			MC_MoveMSFHoriz.Acceleration := horizAccel;
			MC_MoveMSFHoriz.Deceleration := horizDecel;
			MC_MoveMSFHoriz.Position := miniumumPosition;
			
			moveMSFHorizTimeout.PT := MoveTimeoutCalc(MC_MoveMSFHoriz.Position - msfHorizActualPosition, horizVelo, 1000);
			moveMSFHorizTimeout.IN := TRUE;
			MC_MoveMSFHoriz.Execute := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Moving IN to Bag Open'));
			state := 102;
			nextState := 11;
			

	11:		// 	Move FROM bag feeding position TO bag holding because Bag Is Open
			// 2nd step - move to bag holding at low torque then set InPosition then go back to idle
			MC_MoveMSFHorizTorqueLimited.Velocity := horizVelo;
			MC_MoveMSFHorizTorqueLimited.Acceleration := horizAccel;
			MC_MoveMSFHorizTorqueLimited.Deceleration := horizDecel;
			MC_MoveMSFHorizTorqueLimited.CurrentLimit := bagHoldingCurrent;
			MC_MoveMSFHorizTorqueLimited.Position := bagWidth + 0.5;
			
			moveMSFHorizTimeout.PT := MoveTimeoutCalc(MC_MoveMSFHorizTorqueLimited.Position - msfHorizActualPosition, horizVelo, 1000);
			moveMSFHorizTimeout.IN := TRUE;
			MC_MoveMSFHorizTorqueLimited.Execute := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Moving OUT to Bag Open'));
			state := 101;
			nextState := 103;
			
	
	20:		// Bag Feeding moves 
			// 1st Step - Move to clearance position
			_inPosition := FALSE;
			MC_MoveMSFHoriz.Velocity := horizVelo;
			MC_MoveMSFHoriz.Acceleration := horizAccel;
			MC_MoveMSFHoriz.Deceleration := horizDecel;
			MC_MoveMSFHoriz.Position := bagWidth - clearanceOffset;
			
			moveMSFHorizTimeout.PT := MoveTimeoutCalc(MC_MoveMSFHoriz.Position - msfHorizActualPosition, horizVelo, 1000);
			moveMSFHorizTimeout.IN := TRUE;
			MC_MoveMSFHoriz.Execute := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Moving IN to Clearance'));
			state := 102;
			nextState := 21;
	
	21:		// Bag Feeding moves 
			// 2nd Step - Move flatteners up and out of the way
			verticalAxis.MoveUp();
			
			clearanceDwellTimer.IN := TRUE;
			IF clearanceDwellTimer.Q THEN
				clearanceDwellTimer.IN := FALSE;
				_logger.AddLogItem(CONCAT(_prefix, 'Moved UP to Clearance'));
				state := 22;
			END_IF
			
	22:		// Bag Feeding moves 
			// 3rd Step - Move flatteners to outside of bag width to allow for feed
			MC_MoveMSFHoriz.Velocity := horizVelo;
			MC_MoveMSFHoriz.Acceleration := horizAccel;
			MC_MoveMSFHoriz.Deceleration := horizDecel;
			MC_MoveMSFHoriz.Position := bagWidth + clearanceOffset;
			
			moveMSFHorizTimeout.PT := MoveTimeoutCalc(MC_MoveMSFHoriz.Position - msfHorizActualPosition, horizVelo, 1000);
			moveMSFHorizTimeout.IN := TRUE;
			MC_MoveMSFHoriz.Execute := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Moving OUT to Clearance'));
			state := 102;
			nextState := 103;
	
	30:    // Move Out to Seal (Low torque)
			_inPosition := FALSE;
			MC_MoveMSFHorizTorqueLimited.Velocity := horizVelo;
			MC_MoveMSFHorizTorqueLimited.Acceleration := horizAccel;
			MC_MoveMSFHorizTorqueLimited.Deceleration := horizDecel;
			MC_MoveMSFHorizTorqueLimited.CurrentLimit := bagHoldingCurrent + sealCurrentAddition;
			MC_MoveMSFHorizTorqueLimited.Position := bagWidth + 0.5;
			
			moveMSFHorizTimeout.PT := MoveTimeoutCalc(MC_MoveMSFHorizTorqueLimited.Position - msfHorizActualPosition, horizVelo, 1000);
			moveMSFHorizTimeout.IN := TRUE;
			MC_MoveMSFHorizTorqueLimited.Execute := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Moving OUT LOW TORQUE to Seal'));
			state := 101;
			nextState := 103;
		
	100:	// Cleanup
			MC_HomeMSFHoriz.Execute := FALSE;
			MC_MoveMSFHoriz.Execute := FALSE;
			MC_HaltMSFHoriz.Execute := FALSE;
			MC_MoveMSFHorizTorqueLimited.Execute := FALSE;
			moveMSFHorizTimeout.IN := FALSE;
			homeTimeout.IN := FALSE;
			clearanceDwellTimer.IN := FALSE;
			state := nextState;
	
	101: 	// Wait for Torque Limited Move to complete
			IF MC_MoveMSFHorizTorqueLimited.Error OR moveMSFHorizTimeout.Q THEN
				horizontalFailedToMove.Trigger();
				MC_MoveMSFHorizTorqueLimited.Execute := FALSE;
				MC_HaltMSFHoriz.Execute := TRUE;
				nextState := 0;
				state := 100;
			END_IF
			
			IF MC_MoveMSFHorizTorqueLimited.Done THEN
				moveMSFHorizTimeout.IN := FALSE;
				MC_MoveMSFHorizTorqueLimited.Execute := FALSE;
				state := nextState;
			END_IF
			
	102: 	// Wait for normal move to complete
			IF MC_MoveMSFHoriz.Error OR moveMSFHorizTimeout.Q THEN
				horizontalFailedToMove.Trigger();
				moveMSFHorizTimeout.IN := FALSE;
				MC_MoveMSFHoriz.Execute := FALSE;
				MC_HaltMSFHoriz.Execute := TRUE;
				nextState := 0;
				state := 100;
			END_IF
			
			IF MC_MoveMSFHoriz.Done THEN
				MC_MoveMSFHoriz.Execute := FALSE;
				moveMSFHorizTimeout.IN := FALSE;
				state := nextState;
			END_IF
			
	103:	// Set In Position and go back to idle
			_inPosition := TRUE;
			nextState := 0;
			state := 100;
			
END_CASE

PROPERTY InPosition : BOOL


METHOD BagIsOpen

_bagIsOpen := TRUE;

METHOD ToBagFeed
_toBagFeed := TRUE;

METHOD ToSeal
_toSeal := TRUE;

PROPERTY IsHomed : BOOL

METHOD HomeNow
VAR_INPUT
END_VAR

_homeNow := TRUE;

FUNCTION_BLOCK FB_MotorizedSealFlatteners EXTENDS FB_BaseComponent IMPLEMENTS ISealFlatteners, IHomable
VAR_INPUT
	verticalAxis : IUpDown;
	
	clearanceDwellSetting : REAL;
	bagWidth : REAL;						// Bag width setting; will determine all MSF positions
	horizVelo : REAL := 10;
	horizAccel : REAL := 100;
	horizDecel : REAL := 100;
	bagHoldingCurrent : REAL := 0.8;
	sealCurrentAddition : REAL := 0.3;
	homeTimeoutSetting : TIME := T#20S;		// Timeout for homing attempt
	maximumPosition : REAL := 18.5;
	miniumumPosition : REAL := 7.25;
	clearanceOffset : REAL := 1.0;
END_VAR
VAR_OUTPUT
	msfHorizActualPosition : REAL;
	horizontalFailedToMove : FB_Fault(name := CONCAT(_prefix, 'Horizontal Axis Failed to Move'));
	horizontalFailedToHome : FB_Fault(name := CONCAT(_prefix, 'Horizontal Axis Failed to Home'));
	motorFault : FB_Fault(name := CONCAT(_prefix, 'Motor Fault'));
END_VAR
VAR
	MC_MoveMSFHorizTorqueLimited : Sharp_Motion.MC_MoveAbsoluteTorqueLimited;
	MC_MoveMSFHoriz : Sharp_Motion.MC_MoveAbsolute;
	MC_HomeMSFHoriz : Sharp_Motion.MC_Home;
	MC_HaltMSFHoriz : Sharp_Motion.MC_Halt;
	MC_ResetMSFHoriz : Sharp_Motion.MC_Reset;
	
	horizontalAxisInterface : Sharp_Motion.IAxisRef;
	state : INT;
	_inPosition : BOOL;
	_bagIsOpen : BOOL;
	_toBagFeed : BOOL;
	_toSeal : BOOL;
	_homeNow : BOOL;
	homeTimeout : Standard.TON;
	moveMSFHorizTimeout : Standard.TON;
	clearanceDwellTimer : Standard.TON;
	nextState : INT := 0;					// State to move to after confirmation of physical move
	testInterface : IHomable;
	testBool : BOOL;
END_VAR
VAR_IN_OUT
	horizontalAxis : Sharp_Motion.Axis_REF;
	
END_VAR

{region "Axis Setup"}
// Setup of Motion Commands for MSF Horizonal motor axis
MC_MoveMSFHorizTorqueLimited(Axis := horizontalAxis);
MC_MoveMSFHoriz(Axis := horizontalAxis);
MC_HomeMSFHoriz(Axis := horizontalAxis);
MC_HaltMSFHoriz(Axis := horizontalAxis);
MC_ResetMSFHoriz(Axis := horizontalAxis);  
{endregion}
horizontalAxisInterface := horizontalAxis;
{region "Timers"}
// If homing not complete within reasonable time, error out
homeTimeout(PT := homeTimeoutSetting);
// If flatteners don't reach setpoint in reasonable time, error out
moveMSFHorizTimeout();
	 
clearanceDwellTimer(PT := TO_TIME(clearanceDwellSetting * 1000));
{endregion}

msfHorizActualPosition := horizontalAxis.ActPos;

IF _reset THEN
	state := 100;
	nextState := 0;
	IF horizontalAxis.Error THEN
		MC_ResetMSFHoriz.Execute := TRUE;
	END_IF
	_reset := FALSE;
END_IF



IF __QUERYINTERFACE(horizontalAxisInterface, testInterface) THEN
	testBool := TRUE;
END_IF
 
CASE state OF
	0:		// Idle
			MC_ResetMSFHoriz.Execute := FALSE;
			IF horizontalAxis.HomingDone
				AND NOT horizontalFailedToMove.Active
				AND NOT motorFault.Active
			THEN
				_ready := TRUE;
			ELSE
				_ready := FALSE;
			END_IF
			
			IF _bagIsOpen THEN
				state := 10;
				_inPosition := FALSE;
				_bagIsOpen := FALSE;
			END_IF
			
			IF _toBagFeed THEN
				state := 20;
				_inPosition := FALSE;
				_toBagFeed := FALSE;
			END_IF
			
			IF _toSeal THEN
				state := 30;
				_inPosition := FALSE;
				_toSeal := FALSE;
			END_IF
			
			IF _homeNow THEN
				_inPosition := FALSE;
				IF NOT horizontalAxis.HomingDone THEN
					MC_HomeMSFHoriz.Execute := TRUE;
					state := 1;
				END_IF
				_homeNow := FALSE;
			END_IF
			
	1:		// Homing
			homeTimeout.IN := TRUE;
			verticalAxis.MoveUp();
			IF homeTimeout.Q 
				OR MC_HomeMSFHoriz.Error 
				OR UN00_Globals.simFaults.msfHorizontalFailedToHome
			THEN
				horizontalFailedToHome.Trigger();
				state := 100;
			END_IF
			IF MC_HomeMSFHoriz.Done THEN
				state := 100;
			END_IF
			
			
	2:		// 
			
	
		
	

			
			
			
	4: 		// 
	
	5:		// 
	
	6:		// 
	
	7:		//

	10:		// Move FROM bag feeding position TO bag holding because Bag Is Open
			// 1st step: Move In
			
			verticalAxis.MoveDown();
			MC_MoveMSFHoriz.Velocity := horizVelo;
			MC_MoveMSFHoriz.Acceleration := horizAccel;
			MC_MoveMSFHoriz.Deceleration := horizDecel;
			MC_MoveMSFHoriz.Position := miniumumPosition;
			
			moveMSFHorizTimeout.PT := MoveTimeoutCalc(MC_MoveMSFHoriz.Position - msfHorizActualPosition, horizVelo, 1000);
			moveMSFHorizTimeout.IN := TRUE;
			MC_MoveMSFHoriz.Execute := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Moving IN to Bag Open'));
			state := 102;
			nextState := 11;
			

	11:		// 	Move FROM bag feeding position TO bag holding because Bag Is Open
			// 2nd step - move to bag holding at low torque then set InPosition then go back to idle
			MC_MoveMSFHorizTorqueLimited.Velocity := horizVelo;
			MC_MoveMSFHorizTorqueLimited.Acceleration := horizAccel;
			MC_MoveMSFHorizTorqueLimited.Deceleration := horizDecel;
			MC_MoveMSFHorizTorqueLimited.CurrentLimit := bagHoldingCurrent;
			MC_MoveMSFHorizTorqueLimited.Position := bagWidth + 0.5;
			
			moveMSFHorizTimeout.PT := MoveTimeoutCalc(MC_MoveMSFHorizTorqueLimited.Position - msfHorizActualPosition, horizVelo, 1000);
			moveMSFHorizTimeout.IN := TRUE;
			MC_MoveMSFHorizTorqueLimited.Execute := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Moving OUT to Bag Open'));
			state := 101;
			nextState := 103;
			
	
	20:		// Bag Feeding moves 
			// 1st Step - Move to clearance position
			_inPosition := FALSE;
			MC_MoveMSFHoriz.Velocity := horizVelo;
			MC_MoveMSFHoriz.Acceleration := horizAccel;
			MC_MoveMSFHoriz.Deceleration := horizDecel;
			MC_MoveMSFHoriz.Position := bagWidth - clearanceOffset;
			
			moveMSFHorizTimeout.PT := MoveTimeoutCalc(MC_MoveMSFHoriz.Position - msfHorizActualPosition, horizVelo, 1000);
			moveMSFHorizTimeout.IN := TRUE;
			MC_MoveMSFHoriz.Execute := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Moving IN to Clearance'));
			state := 102;
			nextState := 21;
	
	21:		// Bag Feeding moves 
			// 2nd Step - Move flatteners up and out of the way
			verticalAxis.MoveUp();
			
			clearanceDwellTimer.IN := TRUE;
			IF clearanceDwellTimer.Q THEN
				clearanceDwellTimer.IN := FALSE;
				_logger.AddLogItem(CONCAT(_prefix, 'Moved UP to Clearance'));
				state := 22;
			END_IF
			
	22:		// Bag Feeding moves 
			// 3rd Step - Move flatteners to outside of bag width to allow for feed
			MC_MoveMSFHoriz.Velocity := horizVelo;
			MC_MoveMSFHoriz.Acceleration := horizAccel;
			MC_MoveMSFHoriz.Deceleration := horizDecel;
			MC_MoveMSFHoriz.Position := bagWidth + clearanceOffset;
			
			moveMSFHorizTimeout.PT := MoveTimeoutCalc(MC_MoveMSFHoriz.Position - msfHorizActualPosition, horizVelo, 1000);
			moveMSFHorizTimeout.IN := TRUE;
			MC_MoveMSFHoriz.Execute := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Moving OUT to Clearance'));
			state := 102;
			nextState := 103;
	
	30:    // Move Out to Seal (Low torque)
			_inPosition := FALSE;
			MC_MoveMSFHorizTorqueLimited.Velocity := horizVelo;
			MC_MoveMSFHorizTorqueLimited.Acceleration := horizAccel;
			MC_MoveMSFHorizTorqueLimited.Deceleration := horizDecel;
			MC_MoveMSFHorizTorqueLimited.CurrentLimit := bagHoldingCurrent + sealCurrentAddition;
			MC_MoveMSFHorizTorqueLimited.Position := bagWidth + 0.5;
			
			moveMSFHorizTimeout.PT := MoveTimeoutCalc(MC_MoveMSFHorizTorqueLimited.Position - msfHorizActualPosition, horizVelo, 1000);
			moveMSFHorizTimeout.IN := TRUE;
			MC_MoveMSFHorizTorqueLimited.Execute := TRUE;
			_logger.AddLogItem(CONCAT(_prefix, 'Moving OUT LOW TORQUE to Seal'));
			state := 101;
			nextState := 103;
		
	100:	// Cleanup
			MC_HomeMSFHoriz.Execute := FALSE;
			MC_MoveMSFHoriz.Execute := FALSE;
			MC_HaltMSFHoriz.Execute := FALSE;
			MC_MoveMSFHorizTorqueLimited.Execute := FALSE;
			moveMSFHorizTimeout.IN := FALSE;
			homeTimeout.IN := FALSE;
			clearanceDwellTimer.IN := FALSE;
			state := nextState;
	
	101: 	// Wait for Torque Limited Move to complete
			IF MC_MoveMSFHorizTorqueLimited.Error OR moveMSFHorizTimeout.Q THEN
				horizontalFailedToMove.Trigger();
				MC_MoveMSFHorizTorqueLimited.Execute := FALSE;
				MC_HaltMSFHoriz.Execute := TRUE;
				nextState := 0;
				state := 100;
			END_IF
			
			IF MC_MoveMSFHorizTorqueLimited.Done THEN
				moveMSFHorizTimeout.IN := FALSE;
				MC_MoveMSFHorizTorqueLimited.Execute := FALSE;
				state := nextState;
			END_IF
			
	102: 	// Wait for normal move to complete
			IF MC_MoveMSFHoriz.Error OR moveMSFHorizTimeout.Q THEN
				horizontalFailedToMove.Trigger();
				moveMSFHorizTimeout.IN := FALSE;
				MC_MoveMSFHoriz.Execute := FALSE;
				MC_HaltMSFHoriz.Execute := TRUE;
				nextState := 0;
				state := 100;
			END_IF
			
			IF MC_MoveMSFHoriz.Done THEN
				MC_MoveMSFHoriz.Execute := FALSE;
				moveMSFHorizTimeout.IN := FALSE;
				state := nextState;
			END_IF
			
	103:	// Set In Position and go back to idle
			_inPosition := TRUE;
			nextState := 0;
			state := 100;
			
END_CASE

PROPERTY InPosition : BOOL


METHOD BagIsOpen

_bagIsOpen := TRUE;

METHOD ToBagFeed
_toBagFeed := TRUE;

METHOD ToSeal
_toSeal := TRUE;

PROPERTY IsHomed : BOOL

METHOD HomeNow
VAR_INPUT
END_VAR

_homeNow := TRUE;