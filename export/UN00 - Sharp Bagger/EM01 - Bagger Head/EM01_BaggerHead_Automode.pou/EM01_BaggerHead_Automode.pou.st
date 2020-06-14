(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK EM01_BaggerHead_Automode EXTENDS FB_PackMLStates
VAR_INPUT
	infeed : IEM00_Product_Infeed;
	discharge : IEM02_Discharge;
	alarmActive : BOOL;
	resetCMD : BOOL;

END_VAR
VAR_OUTPUT
	state : HEAD_STATES;
    sealAndSeparateSubState : SEAL_SEPARATE_STATES;
    releaseAndFeedSubState : RELEASE_FEED_STATES;
    bagOpenSubState : BAG_OPEN_ASSIST_STATES;
	currentBaggerState : STRING;
END_VAR
VAR
	cycleTimer : TON() := (PT := T#1000S);
	cycleTime : REAL;
	resetTriggered : BOOL;
	resetFailed : BOOL;
	resettingState : INT;
	resettingTimer : Standard.TON := (PT := T#200MS);
	vacuumDwellTimer : TON;
END_VAR
VAR_IN_OUT
	bagger : EM01_BaggerHead;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: EM01_Bagger_Automode
//	Description: This is an implementation of a bagger in Auto Mode (normal operation) using the PackML standard.
//				 Each method is a PackML state.
//	Created by: Ben Hess
//	Created Date: Tuesday, March 26, 2019
resettingTimer();