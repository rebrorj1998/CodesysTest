(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CollisionDetection EXTENDS FB_BaseComponent
VAR_INPUT
	trafficDetected : BOOL;
	trafficDetectedRunoffDwell : REAL;
	packageOnTrunkRunoffDwell : REAL;
	packageAtExit : BOOL;
	multiplePackagesHeld : BOOL;
	conveyorsRunning : BOOL;
END_VAR
VAR_OUTPUT
	externalExitConveyorClear : BOOL;
	inhibitExternalExitConveyor : BOOL;
	runExternalExitConveyor : BOOL;
	runExitConveyor : BOOL;
	packageHeld : BOOL;
	triggerBarcodeScanner : BOOL;
END_VAR
VAR
	_enabledONS : FB_ONS;
	_collisionState : COLLISION_ENGINE_STATE;
	_packageOnTrunkRunoffTimer : Standard.TON;
	_trafficMuted : BOOL;
	_trafficState : TRAFFIC_ENGINE_STATE;
	_trafficDetected : BOOL;
	_packageAtExitONS : Standard.R_TRIG;
	_trafficDetectedRunoffTimer : Standard.TON;
	_debounceTimer : Standard.TON := (PT := T#250MS);
	_packageToTrunklineTimeoutTimer : Standard.TON := (PT := T#3S);
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

// Timeout timer used to make sure package moves from incline to trunkline
_packageToTrunklineTimeoutTimer();

// How long rearExitConveyor runs after bags on trunkline
_packageOnTrunkRunoffTimer(PT := SECS_TO_MS(packageOnTrunkRunoffDwell));

// Used to make sure traffic detect stays high if a package is positioned oddly betweeen two sensors
// Starts when first PE sees a package, continues for set duration
_trafficDetectedRunoffTimer(PT := SECS_TO_MS(trafficDetectedRunoffDwell));

// If reset or not enabled clear paramaters
_enabledONS(CLK := enable);
IF resetONS.Q OR _enabledONS.OSF THEN
	_trafficState := TRAFFIC_ENGINE_STATE.Idle;
	_collisionState := COLLISION_ENGINE_STATE.Idle;
END_IF

//
_packageAtExitONS(CLK := packageAtExit);

// Traffic State Engine; Used to monitor packages coming down the trunk line
CASE _trafficState OF
	
	TRAFFIC_ENGINE_STATE.Idle:
	
		_trafficDetected := FALSE;
		_trafficDetectedRunoffTimer.IN := FALSE;
		
		// If traffic detected while enabled, start sequence
		IF enable THEN
			IF trafficDetected AND NOT _trafficMuted THEN
				_trafficDetected := TRUE;
				_trafficState := TRAFFIC_ENGINE_STATE.TrafficDetected;
			END_IF
		END_IF
		
	TRAFFIC_ENGINE_STATE.TrafficDetected:
		_trafficDetectedRunoffTimer.IN := TRUE;
		_trafficState := TRAFFIC_ENGINE_STATE.TrafficActive;
	
	TRAFFIC_ENGINE_STATE.TrafficActive:
		IF NOT trafficDetected AND _trafficDetectedRunoffTimer.Q THEN
			_trafficState := TRAFFIC_ENGINE_STATE.TrafficEnded;
		END_IF
	
	TRAFFIC_ENGINE_STATE.TrafficEnded:
		_trafficDetected := FALSE;
		_trafficDetectedRunoffTimer.IN := FALSE;
		_trafficState := TRAFFIC_ENGINE_STATE.Idle;
		
END_CASE

// Collision State Engine; Used to 
CASE _collisionState OF
	
	COLLISION_ENGINE_STATE.Idle:
		
		// Clear Params
		externalExitConveyorClear := TRUE;
		runExitConveyor := FALSE;
		triggerBarcodeScanner := FALSE;
		runExternalExitConveyor := FALSE;
		inhibitExternalExitConveyor := FALSE;
		packageHeld := FALSE;
		_trafficMuted := FALSE;
		_packageOnTrunkRunoffTimer.IN := FALSE;
		
		// If package has reached the end of the conveyor, check for collision
		IF packageAtExit AND conveyorsRunning THEN
			_collisionState := COLLISION_ENGINE_STATE.PackageAtExit;
		END_IF
	
	COLLISION_ENGINE_STATE.PackageAtExit:
		// If the product reaches the exit sensor while a collision is detected, inhibit the external exit conveyor
		IF _trafficDetected THEN
			externalExitConveyorClear := FALSE;
			inhibitExternalExitConveyor := TRUE;
			_collisionState := COLLISION_ENGINE_STATE.PackageHeldAtExit;
		ELSE
			_collisionState := COLLISION_ENGINE_STATE.WaitForPackageToReachTrunkline;
		END_IF
		
	COLLISION_ENGINE_STATE.WaitForPackageToReachTrunkline:
		//
		_debounceTimer.IN := NOT packageAtExit;
		IF _debounceTimer.Q THEN
			_debounceTimer.IN := FALSE;
			_collisionState := COLLISION_ENGINE_STATE.Idle;
		END_IF
	
	COLLISION_ENGINE_STATE.PackageHeldAtExit:
		// Wait for the collision to clear and then move on
		packageHeld := TRUE;
		IF NOT _trafficDetected THEN
			inhibitExternalExitConveyor := FALSE;
			packageHeld := FALSE;
			_trafficMuted := TRUE;
			_collisionState := COLLISION_ENGINE_STATE.runConveyors;
		END_IF
	
	COLLISION_ENGINE_STATE.runConveyors:
		runExternalExitConveyor := TRUE;
		IF multiplePackagesHeld THEN
			// Used to push second package to the rear exit conveyor
			runExitConveyor := TRUE;
			triggerBarcodeScanner := TRUE;
		END_IF
		_collisionState := COLLISION_ENGINE_STATE.ConveyFirstPackage;
			
	COLLISION_ENGINE_STATE.ConveyFirstPackage:
		// Make sure the package is fully removed from conveyor before moving on
		_debounceTimer.IN := NOT packageAtExit;
		_packageToTrunklineTimeoutTimer.IN := TRUE;
		IF _debounceTimer.Q OR _packageToTrunklineTimeoutTimer.Q THEN
			_debounceTimer.IN := FALSE;
			_packageToTrunklineTimeoutTimer.IN := FALSE;
			// Continue to package 2 logic if in queue, otherwise finish up
			IF NOT multiplePackagesHeld THEN
				_collisionState := COLLISION_ENGINE_STATE.Idle;
			ELSE
				_collisionState := COLLISION_ENGINE_STATE.WaitForSecondPackage;
			END_IF
		END_IF	
				
	COLLISION_ENGINE_STATE.WaitForSecondPackage:
		//
		IF packageAtExit THEN
			// If a collision is detected when the 2nd package reachs the exit sensor
			// kill the conveyors and return back to package at exit
			IF _packageAtExitONS.Q THEN
				_trafficMuted := FALSE;
			ELSE
				runExitConveyor := FALSE;
				triggerBarcodeScanner := FALSE;
				IF _trafficDetected THEN
					externalExitConveyorClear := TRUE;
					runExternalExitConveyor := FALSE;
					_collisionState := COLLISION_ENGINE_STATE.PackageAtExit;
				ELSE
					_collisionState := COLLISION_ENGINE_STATE.ConveySecondPackage;
				END_IF
			END_IF
		END_IF	
		
	COLLISION_ENGINE_STATE.ConveySecondPackage:
		//
		_debounceTimer.IN := NOT packageAtExit;
		_packageToTrunklineTimeoutTimer.IN := TRUE;
		IF _debounceTimer.Q OR _packageToTrunklineTimeoutTimer.Q THEN
			_debounceTimer.IN := FALSE;
			_packageToTrunklineTimeoutTimer.IN := FALSE;
			_collisionState := COLLISION_ENGINE_STATE.Idle;
		END_IF
	
END_CASE      