(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CollisionDetection EXTENDS FB_BaseComponent
VAR_INPUT
	collisionDetected : BOOL;
	collisionDetectedDwell : REAL;
	collisionEngineRunoffDwell : REAL;
	packageAtExit : BOOL;
	multiplePackagesHeld : BOOL;
	conveyorsActive : BOOL;
END_VAR
VAR_OUTPUT
	conveyorCleared : BOOL;
	inhibitExternalExitConveyor : BOOL;
	runExternalExitConveyor : BOOL;
	runExitConveyor : BOOL;
	packageHeldByCollisionDetection : BOOL;
	triggerBarcodeScanner : BOOL;
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
	_muteColisionDetection : BOOL;
	_packageAtExitTimer : Standard.TON := (PT := T#20MS);
	_debounceTimer : Standard.TON := (PT := T#250MS);
	_testINT : INT;
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
SUPER^();

// Initalize timer.
_debounceTimer();

// Initalize timer. Used to mute the fins on the rear exit conveyor 
_packageAtExitTimer( IN := packageAtExit);

// Initalize timer. How long rearExitConveyor runs after bags on trunkline
_collisionEngineRunoffTimer(PT := SECONDS_TO_TIME(collisionEngineRunoffDwell));

// Initalize timer, if complete, turn off timer.
// Times how long collision detected stays high when triggered 
_collisionDetectionTimer(PT := SECONDS_TO_TIME(collisionDetectedDwell));
IF _collisionDetectionTimer.Q THEN
	_collisionDetectionTimer.IN := FALSE;
END_IF

// If reset or not enabled clear paramaters
_enabledONS(CLK := enable);
IF resetONS.Q OR _enabledONS.OSF THEN
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
		IF collisionDetected AND enable AND NOT _muteColisionDetection THEN
			_collisionDetected := TRUE;
			_collisionDetectionState := COLLISION_DETECTION_STATE.CollisionDetected;
		END_IF
		
	COLLISION_DETECTION_STATE.CollisionDetected:
		_collisionDetectionTimer.IN := TRUE;
		_collisionDetectionState := COLLISION_DETECTION_STATE.CollisionActive;
	
	COLLISION_DETECTION_STATE.CollisionActive:
		IF NOT collisionDetected AND NOT _collisionDetectionTimer.IN THEN
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
		triggerBarcodeScanner := FALSE;
		runExternalExitConveyor := FALSE;
		_muteColisionDetection := FALSE;
		_collisionEngineRunoffTimer.IN := FALSE;
		_conveyorState := CONVEY_PACKAGES_STATE.Idle;
		inhibitExternalExitConveyor := FALSE;
		packageHeldByCollisionDetection := FALSE;
		
		// If package has reached the end of the conveyor, check for collision
		IF _packageAtExitTimer.Q AND conveyorsActive THEN
			_collisionEngineState := COLLISION_ENGINE_STATE.PackageAtExit;
		END_IF
	
	COLLISION_ENGINE_STATE.PackageAtExit:
		// If the product reaches the exit sensor while a collision is detected, inhibit the external exit conveyor
		IF _collisionDetected THEN
			conveyorCleared := FALSE;
			inhibitExternalExitConveyor := TRUE;
			_collisionEngineState := COLLISION_ENGINE_STATE.PackageHeldAtExit;
		ELSE
			_collisionEngineState := COLLISION_ENGINE_STATE.WaitForPackageToReachTrunkline;
		END_IF
		
	COLLISION_ENGINE_STATE.WaitForPackageToReachTrunkline:
	
		_debounceTimer.IN := NOT _packageAtExitTimer.Q;
		IF _debounceTimer.Q THEN
			_debounceTimer.IN := FALSE;
			_collisionEngineState := COLLISION_ENGINE_STATE.Idle;
		END_IF
	
	COLLISION_ENGINE_STATE.PackageHeldAtExit:
		// Wait for the collision to clear and then move on
		packageHeldByCollisionDetection := TRUE;
		IF NOT _collisionDetected THEN
			_muteColisionDetection := TRUE;
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
					// Used to push sencond package to the rear exit conveyor
					runExitConveyor := TRUE;
					triggerBarcodeScanner := TRUE;
				END_IF
				_conveyorState := CONVEY_PACKAGES_STATE.ConveyFirstPackage;
				
			CONVEY_PACKAGES_STATE.ConveyFirstPackage:
				// Make sure the package is fully removed from conveyor before moving on
				_debounceTimer.IN := NOT _packageAtExitTimer.Q;
				IF _debounceTimer.Q THEN
					_debounceTimer.IN := FALSE;
					// Continue to package 2 logic if in queue, otherwise finish up
					IF NOT multiplePackagesHeld THEN
						_conveyorState := CONVEY_PACKAGES_STATE.Runoff;
					ELSE
						_conveyorState := CONVEY_PACKAGES_STATE.WaitForSecondPackage;
					END_IF
				END_IF
				
			CONVEY_PACKAGES_STATE.WaitForSecondPackage:
				IF _packageAtExitTimer.Q THEN
					// If a collision is detected when the 2nd package reachs the exit sensor
					// kill the conveyors and return back to package at exit
					runExitConveyor := FALSE;
					triggerBarcodeScanner := FALSE;
					IF _collisionDetected THEN
						conveyorCleared := TRUE;
						runExternalExitConveyor := FALSE;
						_conveyorState := CONVEY_PACKAGES_STATE.Idle;
						_collisionEngineState := COLLISION_ENGINE_STATE.PackageAtExit;
					ELSE
						_conveyorState := CONVEY_PACKAGES_STATE.ConveySecondPackage;
					END_IF
				ELSIF packageAtExit AND NOT _packageAtExitTimer.Q THEN
					_muteColisionDetection := FALSE;
				END_IF
			
			CONVEY_PACKAGES_STATE.ConveySecondPackage:
				_debounceTimer.IN := NOT _packageAtExitTimer.Q;
				IF _debounceTimer.Q THEN
					_debounceTimer.IN := FALSE;
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
	
END_CASE      