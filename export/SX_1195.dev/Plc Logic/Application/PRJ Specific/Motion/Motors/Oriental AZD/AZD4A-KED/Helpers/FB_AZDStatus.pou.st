(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_AZDStatus
VAR_INPUT
	data : UINT;
	mode : eAZDProfileMode;
END_VAR
VAR_OUTPUT
	// Base
	readyToSwitchOn : BOOL;
	switchedOn : BOOL;
	operationEnabled : BOOL;
	fault : BOOL;
	voltageEnabled : BOOL;
	quickStop : BOOL;
	switchOnDisabled : BOOL;
	warning : BOOL;
	remote : BOOL;
	targetReached : BOOL;
	internalLimitActive : BOOL;
	TLC : BOOL;
	// PP
	setpointAcknowledge : BOOL;
	followingError : BOOL;
	// PV
	speed : BOOL;
	// HM
	homingError : BOOL;
	homingAttained : BOOL;	
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//
//  FB_AZDStatusBase
//  FB/*/*
//
//  Created by Evan Ische on 6/13/2022.
//  Copyright (C) 2022 Sharp Packaging Systems By Pregis. All rights reserved.
//

//
readyToSwitchOn := data.0;
switchedOn := data.1;
operationEnabled := data.2;
fault := data.3;
voltageEnabled := data.4;
quickStop := data.5;
switchOnDisabled := data.6;
warning := data.7;
remote := data.9;
targetReached := data.10;
internalLimitActive := data.11;
TLC := data.15;

//
CASE mode OF 
	eAZDProfileMode.PP:
		speed := FALSE;
		followingError := data.13;
		setpointAcknowledge := data.12;
		homingError := FALSE;
		homingAttained := FALSE;
	eAZDProfileMode.PV:
		speed := data.12;
		followingError := FALSE;
		setpointAcknowledge := FALSE;
		homingError := FALSE;
		homingAttained := FALSE;
	eAZDProfileMode.HM:
		speed := FALSE;
		followingError := FALSE;
		setpointAcknowledge := FALSE;
		homingError := data.13;
		homingAttained := data.12;
END_CASE