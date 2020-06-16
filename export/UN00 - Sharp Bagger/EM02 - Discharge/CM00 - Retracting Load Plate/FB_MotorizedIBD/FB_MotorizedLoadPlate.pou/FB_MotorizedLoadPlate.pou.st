(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_MotorizedLoadPlate EXTENDS FB_BaseComponent IMPLEMENTS IHomable, IRetractingLoadPlate
VAR_INPUT
	lowerVelo : REAL := 10;											// Motor Velocity
	lowerAccel : REAL := 100.0;										// Motor Acceleration
	lowerDecel : REAL := 100.0;										// Motor Deceleration
	raiseVelo : REAL := 10;											// Motor Velocity
	raiseAccel : REAL := 100.0;										// Motor Acceleration
	raiseDecel : REAL := 100.0;										// Motor Deceleration
	homeTimeoutSetting : TIME := T#20S;								// Timeout for homing attempt
	raisedSetting : REAL := 3.0;
	loweredSetting : REAL := 0;
	dwellSetting : REAL := 1.0;
	raiseShelfPB : BOOL;
	lowerShelfPB : BOOL;
END_VAR
VAR_OUTPUT
	failedToHome : FB_Fault(name := CONCAT(_prefix, 'Failed to Home'));
	motorFault : FB_Fault(name := CONCAT(_prefix, 'Motor Fault'));
	motorCommFault : FB_Fault(name := CONCAT(_prefix, 'Motor Comm Fault'));
	actualPosition : REAL;
END_VAR
VAR
	_homeNow : BOOL;
	_readyToLoad : BOOL;
	_beginDischarge : BOOL;
	_isHomed : BOOL;
	MC_HomeMotor : Sharp_Motion.MC_Home;
	MC_MoveMotorABS : Sharp_Motion.MC_MoveAbsolute;
	MC_MoveMotorTorque : Sharp_Motion.MC_MoveAbsoluteTorqueLimited;
	MC_MoveMotorINC : Sharp_Motion.MC_MoveRelative;
	MC_ResetMotor : Sharp_Motion.MC_Reset;
	MC_HaltMotor : Sharp_Motion.MC_Halt;
	homeTimeout : Standard.TON;
	failedToOpenTimer : Standard.TON;
	dwellTimer : Standard.TON;
	motionFaultTimeOffset : TIME := T#200MS;
	resetTimer: TON := (PT := T#2S);
	state : eMotorizedLoadPlateStates;
END_VAR
VAR_IN_OUT
	loadPlateMotor : Sharp_Motion.Axis_REF;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_MotorizedIBD()
//	Description: Motorized Independent Bag Deflator
//				 
//	Created by: Ben Hess
//	Created Date: Tuesday, June 2nd 2020

SUPER^();

{region "Axis Setup"}
// Setup of Motion Commands for passthrough motor axis
MC_HomeMotor(Axis := loadPlateMotor);
MC_MoveMotorABS(Axis := loadPlateMotor);
MC_MoveMotorTorque(Axis := loadPlateMotor);
MC_MoveMotorINC(Axis := loadPlateMotor);
MC_ResetMotor(Axis := loadPlateMotor);
MC_HaltMotor(Axis := loadPlateMotor);
{endregion}

_readyToLoad := TO_DINT(loadPlateMotor.ActualPosition * 1000) < TO_DINT(raisedSetting * 1000) + 10 AND TO_DINT(loadPlateMotor.ActualPosition * 1000) > TO_DINT(raisedSetting * 1000) - 10;
_ready := _readyToLoad AND state = eMotorizedLoadPlateStates.Idle;
_isHomed := loadPlateMotor.HomingDone;
{region "Timers"}
// If homing not complete within reasonable time, error out
homeTimeout(PT := homeTimeoutSetting);
// If reset of motors fails state machine must move on
resetTimer(IN := state = eMotorizedLoadPlateStates.Resetting);
// Dwell timer for load shelf
dwellTimer(PT := TO_TIME(dwellSetting * 1000.0));
{endregion}

// Trigger motor faults from drive					
IF loadPlateMotor.Error AND THIS^.OptionActive THEN
	motorFault.faultTrigger := TRUE;
ELSE 
	motorFault.faultTrigger := FALSE;
END_IF

IF NOT loadPlateMotor.CommStatus AND THIS^.OptionActive THEN
	motorCommFault.faultTrigger := TRUE;
ELSE
	motorCommFault.faultTrigger := FALSE;
END_IF

{endregion}

IF _reset THEN
	state := eMotorizedLoadPlateStates.Reset;
	_reset := FALSE;
END_IF



CASE state OF
	
	eMotorizedLoadPlateStates.Idle:
	 		// Idle State.
	   		
				   
				IF _homeNow THEN
					_homeNow := FALSE;
			   		IF THIS^.OptionActive THEN
					   state := eMotorizedLoadPlateStates.Home;
				  	END_IF
					
				END_IF
				
				
				IF raiseShelfPB THEN
			   		IF THIS^.OptionActive THEN
					   state := eMotorizedLoadPlateStates.Raise;
				  	END_IF
				ELSIF _beginDischarge OR lowerShelfPB THEN
					IF THIS^.OptionActive THEN
					   state := eMotorizedLoadPlateStates.Lower;
				  	END_IF
					
				END_IF
							
		  
	   
			MC_ResetMotor.Execute := FALSE;
			IF loadPlateMotor.HomingDone
				AND NOT failedToHome.Active
				AND NOT motorFault.Active
		   		AND NOT motorCommFault.Active
				AND _readyToLoad
			THEN
				_ready := TRUE;
			ELSE
				_ready := FALSE;
			END_IF
					
		
		
	
	eMotorizedLoadPlateStates.Home:	
		// Normal Homing - not factory homing.
		homeTimeout.IN := TRUE;
		// Move the IBD to zero
		MC_HomeMotor.Execute := TRUE;
		state := eMotorizedLoadPlateStates.Homing;
					
					
	eMotorizedLoadPlateStates.Homing:		
		// When ZHomed, Move out to Open s
		IF MC_HomeMotor.Done THEN				
			MC_HomeMotor.Execute := FALSE;
			state := eMotorizedLoadPlateStates.Raise;
		ELSIF MC_HomeMotor.Error OR homeTimeout.Q THEN
			MC_HomeMotor.Execute := FALSE;
			failedToHome.Trigger();
			state := eMotorizedLoadPlateStates.Faulting;
		END_IF
			
	
	eMotorizedLoadPlateStates.Raise:	
		// Move jaw out to passthrough
		MC_MoveMotorABS.Position := raisedSetting;
		MC_MoveMotorABS.Velocity := raiseVelo;
		MC_MoveMotorABS.Acceleration := raiseAccel;
		MC_MoveMotorABS.Deceleration := raiseDecel;
		MC_MoveMotorABS.Execute := TRUE;
		state := eMotorizedLoadPlateStates.Raising;
		
	eMotorizedLoadPlateStates.Raising:
		// wait for jaw to report open
		IF MC_MoveMotorABS.Done THEN
			MC_MoveMotorABS.Execute := FALSE;
			state := eMotorizedLoadPlateStates.Idle;
		ELSIF MC_MoveMotorABS.Error THEN
			MC_MoveMotorABS.Execute := FALSE;
			//failedToOpen.Trigger();
			state := eMotorizedLoadPlateStates.Faulting;
		END_IF
	eMotorizedLoadPlateStates.Raised:
		//
		
	eMotorizedLoadPlateStates.Lower:	
		// Start Moving jaw to closed position
		MC_MoveMotorABS.Position := loweredSetting;
		MC_MoveMotorABS.Velocity := lowerVelo;
		MC_MoveMotorABS.Acceleration := lowerAccel;
		MC_MoveMotorABS.Deceleration := lowerDecel;
		MC_MoveMotorABS.Execute := TRUE;
		state := eMotorizedLoadPlateStates.Lowering;
		
	eMotorizedLoadPlateStates.Lowering:
		// Wait for jaw closed indication
		IF MC_MoveMotorABS.Done THEN
			MC_MoveMotorABS.Execute := FALSE;
	   		IF NOT _beginDischarge THEN
		   		state := eMotorizedLoadPlateStates.Idle;
		   	ELSE
		   		dwellTimer.IN := TRUE;
		   		state := eMotorizedLoadPlateStates.Lowered;
	 	 	END_IF
			
		ELSIF MC_MoveMotorABS.Error THEN
			MC_MoveMotorABS.Execute := FALSE;
			state := eMotorizedLoadPlateStates.Faulting;
		END_IF
   
	eMotorizedLoadPlateStates.Lowered:
		// Stay lowered for dwell time then move shelf back up
   		IF dwellTimer.Q THEN
			dwellTimer.IN := FALSE;
	  		_beginDischarge := FALSE;
			state := eMotorizedLoadPlateStates.Raise;	   
		END_IF
				
		
	eMotorizedLoadPlateStates.Faulting:
		// Free up motors on a fault
		MC_HaltMotor.Execute := TRUE;
		IF MC_HaltMotor.Done OR  MC_HaltMotor.Error THEN
			state := eMotorizedLoadPlateStates.Faulted;
		END_IF
		
	eMotorizedLoadPlateStates.Faulted:
		//
		
		
	eMotorizedLoadPlateStates.Reset:
		//  Send reset to motors if they're faulted
		
		MC_ResetMotor.Execute := TRUE;
		MC_HomeMotor.Execute := FALSE;
		//resetPassthoughMotor.Execute := FALSE;
		MC_MoveMotorABS.Execute := FALSE;
		MC_MoveMotorINC.Execute := FALSE;
		MC_HaltMotor.Execute := FALSE;
		MC_MoveMotorTorque.Execute := FALSE;
		homeTimeout.IN := FALSE;
   		dwellTimer.IN := FALSE;
		_homeNow := FALSE;
		_beginDischarge := FALSE;
		state := eMotorizedLoadPlateStates.Resetting;

	eMotorizedLoadPlateStates.Resetting:
		//
		IF NOT loadPlateMotor.Error OR resetTimer.Q THEN
			MC_ResetMotor.Execute := FALSE;
			state := eMotorizedLoadPlateStates.Idle;
		END_IF
END_CASE