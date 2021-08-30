(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_BaseLoadPlate EXTENDS FB_BaseComponent
VAR_INPUT
	inUse : BOOL;
	extended : BOOL;
	retracted : BOOL;
	faultsEnabled : BOOL;
	triggerDwell : REAL;
	triggerDelay : REAL;
    shakerEnable : BOOL;
	shakerDwell : REAL;
	shakerDelay : REAL;
	shakerOnDuration : REAL;
	shakerOffDuration : REAL;
	shakeStart : SHAKER_START_SELECTION;
	disabledPosition : PackageEjectionDisabledPosition;
	estopOK : BOOL;
END_VAR
VAR_OUTPUT
	retract : BOOL;
	extend : BOOL;
	failedToExtend : BOOL;
	failedToRetract : BOOL;
END_VAR
VAR
	_faultTime : TIME := T#2500MS;
	_shake : BOOL;
	_shaking : BOOL;
	_trigger : BOOL;
	_manualOn : BOOL;
	_manualOff : BOOL;
	_shaker : Util.BLINK;
	_shakerDelayTimer : Standard.TON;
	_shakerDwellTimer : Standard.TON;
	_triggerDelayTimer : Standard.TON;
	_triggerDwellTimer : Standard.TON;
	_extendFaultTimer : Standard.TON;
	_retractFaultTimer : Standard.TON;
	_triggerActiveONS : FB_ONS;
	_shakeActiveONS : FB_ONS;
	_state : LOAD_PLATE_STATE;
	_loadPlateInUseONS : FB_ONS;
	_estopOK : FB_ONS;
	_disabledPositionHasUpdated : BOOL;
	_previousDisabledPosition : PackageEjectionDisabledPosition;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//
//  FB_BaseLoadPlate
//  FBs/Components/LoadPlate/FB_BaseLoadPlate
//
//  Created by Evan Ische on 6/19/2021. 
//  Copyright (C) 2021 Sharp Packaging Systems By Pregis. All rights reserved.
//

SUPER^();

// Null Parameters on reset of cycle completion				   
IF _triggerDwellTimer.Q OR resetONS.Q THEN
	_trigger := FALSE;
	_shaking := FALSE;
	_shakerDelayTimer.IN := FALSE;
	_shakerDwellTimer.IN := FALSE;
	_extendFaultTimer.IN := FALSE;
	_retractFaultTimer.IN := FALSE;
	_state := LOAD_PLATE_STATE.Idle;
END_IF

//
_shakeActiveONS();
_triggerActiveONS();

//
_disabledPositionHasUpdated := FALSE;
IF disabledPosition <> _previousDisabledPosition THEN
	_disabledPositionHasUpdated := TRUE;
	_previousDisabledPosition := disabledPosition;
END_IF 
_estopOK(CLK := estopOK);

//
_loadPlateInUseONS(CLK := inUse); 			
IF RetractLoadPlate THEN
	retract := TRUE;
	_manualOn := FALSE;
ELSIF ExtendLoadPlate THEN
	retract := FALSE;
	_manualOff := FALSE;
END_IF
extend := NOT retract;

// Counts the time between telling an actuator to move positions, and when it gets to the new position. If Timer finished, fault.
_extendFaultTimer(
	IN := extend AND NOT extended AND faultsEnabled,
	PT := _faultTime,
	 Q => failedToExtend);
	 
_retractFaultTimer(
	IN := retract AND NOT retracted AND faultsEnabled,
	PT := _faultTime,
	 Q => failedToRetract);

// How Long To Wait Before Going Active
_triggerDelayTimer(
	IN := _trigger,
	PT := TO_TIME(triggerDelay * 1000),
	Q => _triggerActiveONS.CLK);
	
// Retract Duration
_triggerDwellTimer(
	IN := _triggerDelayTimer.Q,
	PT := TO_TIME(triggerDwell * 1000));
	
// 
_shaker(
	TIMEHIGH := TO_TIME(shakerOnDuration * 1000),
	TIMELOW := TO_TIME(shakerOffDuration * 1000),
	OUT => _shakeActiveONS.CLK
);

//
_shakerDelayTimer(PT := TO_TIME(shakerDelay * 1000));
_shakerDwellTimer(PT := TO_TIME(shakerDwell * 1000));	
CASE _state OF
	LOAD_PLATE_STATE.Idle:
		IF _shake THEN
			_shake := FALSE;
			_state := LOAD_PLATE_STATE.Shake;
		END_IF
	
	LOAD_PLATE_STATE.Shake:
		_shakerDelayTimer.IN := TRUE;
		IF _shakerDelayTimer.Q THEN
			_shakerDelayTimer.IN := FALSE;
			_state := LOAD_PLATE_STATE.Shaking;
		END_IF
	
	LOAD_PLATE_STATE.Shaking:
		// Starts Shaker
		_shaker.ENABLE := TRUE;
		_shakerDwellTimer.IN := TRUE;
		IF _shakerDwellTimer.Q THEN
			// Ends Shaker
			_shaker.ENABLE := FALSE;
			_shakerDwellTimer.IN := FALSE;
			_state := LOAD_PLATE_STATE.Shaked;
		END_IF
	
	LOAD_PLATE_STATE.Shaked:
		IF extended THEN
			_state := LOAD_PLATE_STATE.Idle;
		ELSE
			IF NOT extended THEN
				_manualOff := TRUE;
			END_IF
		END_IF
END_CASE