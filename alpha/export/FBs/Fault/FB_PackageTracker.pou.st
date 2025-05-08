(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_PackageTracker
VAR_INPUT
	atExit : BOOL;
	scanned : BOOL;
	tamped : BOOL;
	enable : BOOL;
END_VAR
VAR_OUTPUT
	clear : BOOL;
END_VAR
VAR
	_state : PACKAGE_TRACKING_STATE;
	_packageAtExitTimer : Standard.TON := (PT := T#20MS);
	_packageNotAtExitTimer : Standard.TON := (PT := T#20MS);
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//
//  FB_FactoryTest
//  FB/Components/Factory Test/FB_FactoryTest
//
//  Created by Evan Ische on 12/07/2021.
//  Copyright (C) 2021 Sharp Packaging Systems By Pregis. All rights reserved.
//

//
_packageAtExitTimer(IN := atExit);
_packageNotAtExitTimer(IN := NOT _packageAtExitTimer.Q);

//
CASE _state OF
	PACKAGE_TRACKING_STATE.Idle:
		clear := FALSE;
		IF tamped THEN
			_state := PACKAGE_TRACKING_STATE.ScanSection;	 
		END_IF 
	PACKAGE_TRACKING_STATE.ScanSection:
		IF scanned THEN
			_state := PACKAGE_TRACKING_STATE.ExitSection;
		END_IF
	PACKAGE_TRACKING_STATE.ExitSection:
		IF _packageAtExitTimer.Q THEN
			_state := PACKAGE_TRACKING_STATE.TrunkSection;	 
		END_IF
	PACKAGE_TRACKING_STATE.TrunkSection:
		IF _packageNotAtExitTimer.Q THEN
			clear := TRUE;
			_state := PACKAGE_TRACKING_STATE.Idle;	
		END_IF	 
END_CASE

// Clear out state engine when no faults are present
IF NOT enable THEN
	_state :=PACKAGE_TRACKING_STATE.Idle;
END_IF