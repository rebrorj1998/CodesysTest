(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_AZDControl
VAR_INPUT
	mode : eAZDProfileMode;
END_VAR
VAR_OUTPUT
	data : UINT;
END_VAR
VAR
	// Base
	_switchOn : BOOL;
	_enableVoltage : BOOL;
	_quickStop : BOOL;
	_enableOperation : BOOL;
	_faultReset : BOOL;
	_halt : BOOL;
	// PP
	_basePositionOfRel : BOOL;
	_changeSetImmidiately : BOOL;
	_newSetPoint : BOOL;
	_profilePositionMode : SINT;
	_push : BOOL;
	_wrap : BOOL;
	// PV
	_profileVelocityMode : SINT;
	//
	_homingOperationStart : BOOL;
	_catchFaultReset : BOOL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//
//  FB_AZDStatusword
//  Application/AZD/FB_AZDControl/FB_AZDStatusword
//
//  Created by Evan Ische on 6/20/2022.
//  Copyright (C) 2022 Sharp Packaging Systems By Pregis. All rights reserved.
//

// Base Parameters
data.0 := _switchOn;
data.1 := _enableVoltage;
data.2 := _quickStop;
data.3 := _enableOperation;
data.7 := _faultReset;
data.8 := _halt;

IF _faultReset THEN
	_catchFaultReset := TRUE;
END_IF

CASE mode OF 
	eAZDProfileMode.PP:
		data.4 := _newSetPoint;
		data.5 := _changeSetImmidiately;
		data.6 := _profilePositionMode.0;
		data.12 := _basePositionOfRel;
		data.13 := _push;
		data.14 := _wrap;
	eAZDProfileMode.PV:
		data.4 := FALSE;
		data.5 := FALSE;
		data.6 := FALSE;
		data.12 := _profileVelocityMode.0;
		data.13 := _profileVelocityMode.1;
		data.14 := FALSE;
 	eAZDProfileMode.HM:
		data.4 := _homingOperationStart;
		data.5 := FALSE;
		data.6 := FALSE;
		data.12 := FALSE;
		data.13 := FALSE;
		data.14 := FALSE;
END_CASE