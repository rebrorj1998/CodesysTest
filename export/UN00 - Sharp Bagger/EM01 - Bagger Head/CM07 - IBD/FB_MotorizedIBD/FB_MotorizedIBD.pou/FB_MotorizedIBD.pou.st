(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_MotorizedIBD EXTENDS FB_BaseIBD IMPLEMENTS IHomable
VAR_INPUT
	closeVelo : REAL := 10;											// IBD Motor Velocity
	closeAccel : REAL := 100.0;										// IBD Motor Acceleration
	closeDecel : REAL := 100.0;										// IBD Motor Deceleration
	closeCurrent : REAL := 50.0;			
	openVelo : REAL := 10;											// IBD Motor Velocity
	openAccel : REAL := 100.0;										// IBD Motor Acceleration
	openDecel : REAL := 100.0;										// IBD Motor Deceleration
	homeTimeoutSetting : TIME := T#10S;								// Timeout for homing attempt
	passthroughSetting : REAL := 5.5;
	jawClosedSetting : REAL := 0;
	openIBDPB : BOOL;
	closeIBDPB : BOOL;
END_VAR
VAR_OUTPUT
	failedToOpen : FB_Fault(name := CONCAT(_prefix, 'Failed to Open'));
	failedToHome : FB_Fault(name := CONCAT(_prefix, 'Failed to Home'));
	IBDMotorFault : FB_Fault(name := CONCAT(_prefix, 'Motor Fault'));
	IBDMotorCommFault : FB_Fault(name := CONCAT(_prefix, 'Motor Comm Fault'));
	actualPosition : REAL := 5.5;
END_VAR
VAR
	_homeNow : BOOL;
	_isFullyOpen : BOOL;
	_isHomed : BOOL;
	MC_HomeIBDMotor : Sharp_Motion.MC_Home;
	MC_MoveIBDMotorABS : Sharp_Motion.MC_MoveAbsolute;
	MC_MoveIBDMotorABSTorque : Sharp_Motion.MC_MoveAbsoluteTorqueLimited;
	MC_MoveIBDMotorINC : Sharp_Motion.MC_MoveRelative;
	MC_ResetIBDMotor : Sharp_Motion.MC_Reset;
	MC_HaltIBDMotor : Sharp_Motion.MC_Halt;
	homeTimeout : Standard.TON;
	failedToOpenTimer : Standard.TON;
	motionFaultTimeOffset : TIME := T#5S;
	resetTimer: TON := (PT := T#2S);
	state : eMotorizedIBDStates;
END_VAR
VAR_IN_OUT
	IBDMotor : Sharp_Motion.Axis_REF;
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
MC_HomeIBDMotor(Axis := IBDMotor);
MC_MoveIBDMotorABS(Axis := IBDMotor);
MC_MoveIBDMotorABSTorque(Axis := IBDMotor);
MC_MoveIBDMotorINC(Axis := IBDMotor);
MC_ResetIBDMotor(Axis := IBDMotor);
MC_HaltIBDMotor(Axis := IBDMotor);
{endregion}

_isFullyOpen := TO_DINT(IBDMotor.ActualPosition * 1000) <= (TO_DINT(passthroughSetting * 1000) + 10) AND TO_DINT(IBDMotor.ActualPosition * 1000) >= (TO_DINT(passthroughSetting * 1000) - 10);

{region "Timers"}
// If homing not complete within reasonable time, error out
homeTimeout(PT := homeTimeoutSetting, IN := state = eMotorizedIBDStates.Homing);
// If reset of motors fails state machine must move on
resetTimer(IN := state = eMotorizedIBDStates.Resetting);
{endregion}

failedToOpenTimer(IN := (state = eMotorizedIBDStates.MovingOut OR state = eMotorizedIBDStates.MovingOutAfterHome) AND NOT _isFullyOpen,
					PT := TO_TIME((passthroughSetting / openVelo) * 1000.0) + motionFaultTimeOffset,
					Q => );
					
// Trigger motor faults from drive					
IF IBDMotor.Error THEN
	//IBDMotorFault.faultTrigger := TRUE;
ELSE 
	//IBDMotorFault.faultTrigger := FALSE;
END_IF

IF NOT IBDMotor.CommStatus THEN
	IBDMotorCommFault.faultTrigger := TRUE;
ELSE
	IBDMotorCommFault.faultTrigger := FALSE;
END_IF


IF homeTimeout.Q 
	//OR MC_HomeIBDMotor.Error 
	OR UN00_Globals.simFaults.pressureBarfailedToHome
THEN
	failedToHome.Trigger();
END_IF
{endregion}

IF _reset THEN
	state := eMotorizedIBDStates.Reset;
	_reset := FALSE;
END_IF



CASE state OF
	
	eMotorizedIBDStates.Idle:
	 		// Idle State.
			MC_ResetIBDMotor.Execute := FALSE;
			IF IBDMotor.HomingDone
				AND NOT failedToOpen.Active
				AND NOT failedToHome.Active
				AND NOT IBDMotorFault.Active
				AND _isFullyOpen
			THEN
				_ready := TRUE;
			ELSE
				_ready := FALSE;
			END_IF
			
			IF _homeNow THEN
				_homeNow := FALSE;
		   		_isHomed := FALSE;
				state := eMotorizedIBDStates.Home;
			END_IF
			
			
			IF _MoveOut OR openIBDPB THEN
				_MoveOut := FALSE;
				state := eMotorizedIBDStates.MoveOut;
			ELSIF _moveInToDeflate OR closeIBDPB THEN
				_moveInToDeflate := FALSE;
				state := eMotorizedIBDStates.MoveIn;
			END_IF
								
		
		
	
	eMotorizedIBDStates.Home:	
		// Normal Homing - not factory homing.
		// Move the IBD to zero
		MC_HomeIBDMotor.Execute := TRUE;
		state := eMotorizedIBDStates.Homing;
					
					
	eMotorizedIBDStates.Homing:		
		// When ZHomed, Move out to Open s
		IF MC_HomeIBDMotor.Done THEN				
			MC_HomeIBDMotor.Execute := FALSE;
	   		// Move jaw out to passthrough
			MC_MoveIBDMotorABS.Position := passthroughSetting;
			MC_MoveIBDMotorABS.Velocity := openVelo;
			MC_MoveIBDMotorABS.Acceleration := openAccel;
			MC_MoveIBDMotorABS.Deceleration := openDecel;
			MC_MoveIBDMotorABS.Execute := TRUE;
			state := eMotorizedIBDStates.MovingOutAfterHome;
		ELSIF MC_HomeIBDMotor.Error THEN
			MC_HomeIBDMotor.Execute := FALSE;
			failedToHome.Trigger();
			state := eMotorizedIBDStates.Faulting;
		END_IF
			
	eMotorizedIBDStates.MovingOutAfterHome:		
		//
   		// wait for jaw to report open
		IF MC_MoveIBDMotorABS.Done THEN
			MC_MoveIBDMotorABS.Execute := FALSE;
	   		_isHomed := TRUE;
			state := eMotorizedIBDStates.Idle;
		ELSIF MC_MoveIBDMotorABS.Error OR failedToOpenTimer.Q THEN
			MC_MoveIBDMotorABS.Execute := FALSE;
			failedToOpen.Trigger();
			state := eMotorizedIBDStates.Faulting;
		END_IF
   
	eMotorizedIBDStates.MoveOut:	
		// Move jaw out to passthrough
		MC_MoveIBDMotorABS.Position := passthroughSetting;
		MC_MoveIBDMotorABS.Velocity := openVelo;
		MC_MoveIBDMotorABS.Acceleration := openAccel;
		MC_MoveIBDMotorABS.Deceleration := openDecel;
		MC_MoveIBDMotorABS.Execute := TRUE;
		state := eMotorizedIBDStates.MovingOut;
		
	eMotorizedIBDStates.MovingOut:
		// wait for jaw to report open
		IF MC_MoveIBDMotorABS.Done THEN
			MC_MoveIBDMotorABS.Execute := FALSE;
			state := eMotorizedIBDStates.Idle;
		ELSIF MC_MoveIBDMotorABS.Error OR failedToOpenTimer.Q THEN
			MC_MoveIBDMotorABS.Execute := FALSE;
			failedToOpen.Trigger();
			state := eMotorizedIBDStates.Faulting;
		END_IF
	eMotorizedIBDStates.MovedOut:
		//
		
	eMotorizedIBDStates.MoveIn:	
		// Start Moving jaw to closed position
		MC_MoveIBDMotorABSTorque.Position := jawClosedSetting;
		MC_MoveIBDMotorABSTorque.Velocity := closeVelo;
		MC_MoveIBDMotorABSTorque.Acceleration := closeAccel;
		MC_MoveIBDMotorABSTorque.Deceleration := closeDecel;
		MC_MoveIBDMotorABSTorque.CurrentLimit := closeCurrent;
		MC_MoveIBDMotorABSTorque.Execute := TRUE;
		state := eMotorizedIBDStates.MovingIn;
		
	eMotorizedIBDStates.MovingIn:
		// Wait for jaw closed indication
		IF MC_MoveIBDMotorABSTorque.Done THEN
			MC_MoveIBDMotorABSTorque.Execute := FALSE;
			state := eMotorizedIBDStates.Idle;
		ELSIF MC_MoveIBDMotorABSTorque.Error THEN
			MC_MoveIBDMotorABSTorque.Execute := FALSE;
			state := eMotorizedIBDStates.Faulting;
		END_IF
	eMotorizedIBDStates.MovedIn:
		//
		
	eMotorizedIBDStates.Faulting:
		// Free up motors on a fault
		MC_HaltIBDMotor.Execute := TRUE;
		IF MC_HaltIBDMotor.Done OR  MC_HaltIBDMotor.Error THEN
			state := eMotorizedIBDStates.Faulted;
		END_IF
		
	eMotorizedIBDStates.Faulted:
		//
		
		
	eMotorizedIBDStates.Reset:
		//  Send reset to motors if they're faulted
		//IF IBDMotor.Error THEN
			MC_ResetIBDMotor.Execute := TRUE;
		//END_IF
		MC_HomeIBDMotor.Execute := FALSE;
		//resetPassthoughMotor.Execute := FALSE;
		MC_MoveIBDMotorABS.Execute := FALSE;
		MC_MoveIBDMotorINC.Execute := FALSE;
		MC_HaltIBDMotor.Execute := FALSE;
		MC_MoveIBDMotorABSTorque.Execute := FALSE;
		_homeNow := FALSE;
		_moveOut := FALSE;
		_moveInToDeflate := FALSE;
		state := eMotorizedIBDStates.Resetting;

	eMotorizedIBDStates.Resetting:
		//
		IF NOT IBDMotor.Error OR resetTimer.Q THEN
			MC_ResetIBDMotor.Execute := FALSE;
			state := eMotorizedIBDStates.Idle;
		END_IF
END_CASE