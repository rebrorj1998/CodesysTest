(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_CollisionDetection EXTENDS FB_BaseComponent
VAR_INPUT
	collisionDetected : BOOL;
	collisionDetectedDwell : REAL;
	collisionEngineRunoffDwell : REAL;
	packageAtExit : BOOL;
	multiplePackagesHeld : BOOL;
END_VAR
VAR_OUTPUT
	conveyorCleared : BOOL;
	inhibitExternalExitConveyor : BOOL;
	runExternalExitConveyor : BOOL;
	runExitConveyor : BOOL;
	packageHeldByCollisionDetection : BOOL;
END_VAR
VAR
	_enabledONS : FB_ONS;
	_conveyorState : CONVEY_PACKAGES_STATE;
	_collisionEngineState : COLLISION_ENGINE_STATE;
	_collisionEngineRunoffTimer : Standard.TON;
	_collisionDetectionState : COLLISION_DETECTION_STATE;
	_collisionDetected : BOOL;
	_collisionDetectionONS : FB_ONS;
	_collisionDetectionTimer : Standard.TON;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//
//  FB_CollisionDetection
//  FBs/Components/Collisiton Detection/FB_CollisionDetection
//
//  Created by Evan Ische on 8/20/2021.
//  Copyright (C) 2021 Sharp Packaging Systems By Pregis. All rights reserved.
//

//
_collisionEngineRunoffTimer(PT := SECONDS_TO_TIME(collisionEngineRunoffDwell));

// Initalize timer, if complete, turn off timer. 
_collisionDetectionTimer(PT := SECONDS_TO_TIME(collisionDetectedDwell));
IF _collisionDetectionTimer.Q THEN
	_collisionDetectionTimer.IN := FALSE;
END_IF

// If reset or not enabled clear paramaters
_enabledONS(CLK := enable);
IF resetONS.Q OR NOT _enabledONS.OSF THEN
	_conveyorState := CONVEY_PACKAGES_STATE.Idle;
	_collisionDetectionState := COLLISION_DETECTION_STATE.Idle;
	_collisionEngineState := COLLISION_ENGINE_STATE.Idle;
END_IF

// Collision Detection State Engine
CASE _collisionDetectionState OF

	COLLISION_DETECTION_STATE.Idle:
	
		// Null Parameters
		_collisionDetected := FALSE;
		_collisionDetectionTimer.IN := FALSE;
		
		// If collision detected while enabled, start sequence
		IF collisionDetected AND enable THEN
			_collisionDetectionState := COLLISION_DETECTION_STATE.CollisionDetected;
		END_IF
		
	COLLISION_DETECTION_STATE.CollisionDetected:
		_collisionDetected := TRUE;
		_collisionDetectionTimer.IN := TRUE;
		_collisionDetectionState := COLLISION_DETECTION_STATE.CollisionActive;
	
	COLLISION_DETECTION_STATE.CollisionActive:
		IF NOT _collisionDetected AND NOT _collisionDetectionTimer.IN THEN
			_collisionDetectionState := COLLISION_DETECTION_STATE.CollisionEnded;
		END_IF
	
	COLLISION_DETECTION_STATE.CollisionEnded:
		_collisionDetected := FALSE;
		_collisionDetectionState := COLLISION_DETECTION_STATE.Idle;
	
END_CASE

// Collision Active State Engine
CASE _collisionEngineState OF
	
	COLLISION_ENGINE_STATE.Idle:
		
		// Null Parameters
		conveyorCleared := TRUE;
		runExitConveyor := FALSE;
		runExternalExitConveyor := FALSE;
		inhibitExternalExitConveyor := FALSE;
		_collisionEngineRunoffTimer.IN := FALSE;
		_conveyorState := CONVEY_PACKAGES_STATE.Idle;
		
		// If package has reached the end of the conveyor, check for collision
		IF packageAtExit THEN
			_collisionEngineState := COLLISION_ENGINE_STATE.PackageAtExit;
		END_IF
	
	COLLISION_ENGINE_STATE.PackageAtExit:
		// If the product reaches the exit sensor while a collision is detected, inhibit the external exit conveyor
		IF _collisionDetected THEN
			conveyorCleared := FALSE;
			inhibitExternalExitConveyor := TRUE;
			_collisionEngineState := COLLISION_ENGINE_STATE.PackageHeldAtExit;
		ELSE
			_collisionEngineState := COLLISION_ENGINE_STATE.Idle;
		END_IF
	
	COLLISION_ENGINE_STATE.PackageHeldAtExit:
		// Wait for the collision to clear and then move on
		packageHeldByCollisionDetection := TRUE;
		IF NOT _collisionDetected THEN
			packageHeldByCollisionDetection := FALSE;
			inhibitExternalExitConveyor := FALSE;
			_collisionEngineState := COLLISION_ENGINE_STATE.ConveyPackagesPastExitSensor;
		END_IF
	
	COLLISION_ENGINE_STATE.ConveyPackagesPastExitSensor:
		
		//
		CASE _conveyorState OF 
			CONVEY_PACKAGES_STATE.Idle:
				_conveyorState := CONVEY_PACKAGES_STATE.StartConveyor;
				
			CONVEY_PACKAGES_STATE.StartConveyor:
				runExternalExitConveyor := TRUE;
				IF multiplePackagesHeld THEN
					runExitConveyor := TRUE;
				END_IF
				_conveyorState := CONVEY_PACKAGES_STATE.ConveyFirstPackage;
				
			CONVEY_PACKAGES_STATE.ConveyFirstPackage:
				IF NOT packageAtExit THEN
					IF NOT multiplePackagesHeld THEN
						_conveyorState := CONVEY_PACKAGES_STATE.Runoff;
					ELSE
						_conveyorState := CONVEY_PACKAGES_STATE.WaitForSecondPackage;
					END_IF
				END_IF
				
			CONVEY_PACKAGES_STATE.WaitForSecondPackage:
				runExitConveyor := FALSE;
				IF packageAtExit THEN
					_conveyorState := CONVEY_PACKAGES_STATE.ConveySecondPackage;
				END_IF
			
			CONVEY_PACKAGES_STATE.ConveySecondPackage:
				IF NOT packageAtExit THEN
					_conveyorState := CONVEY_PACKAGES_STATE.Runoff;
				END_IF
			
			CONVEY_PACKAGES_STATE.Runoff:
				_collisionEngineRunoffTimer.IN := TRUE;
				IF _collisionEngineRunoffTimer.Q THEN
					_conveyorState := CONVEY_PACKAGES_STATE.ConveyorCleared;
				END_IF
			
			CONVEY_PACKAGES_STATE.ConveyorCleared:
				_collisionEngineState := COLLISION_ENGINE_STATE.Idle;
		END_CASE
		
		//
		IF _collisionDetected THEN
			
			// Null Parameters
			_collisionEngineRunoffTimer.IN := FALSE;
		
			//
			IF multiplePackagesHeld THEN 
				IF packageAtExit THEN
					conveyorCleared := TRUE;
					runExitConveyor := FALSE;
					runExternalExitConveyor := FALSE;
					_conveyorState := CONVEY_PACKAGES_STATE.Idle;
					_collisionEngineState := COLLISION_ENGINE_STATE.PackageAtExit;
				END_IF
			ELSE 
				runExitConveyor := FALSE;
				runExternalExitConveyor := FALSE;
				_conveyorState := CONVEY_PACKAGES_STATE.Idle;
				_collisionEngineState := COLLISION_ENGINE_STATE.Idle;
			END_IF
			
		END_IF
	
END_CASE      