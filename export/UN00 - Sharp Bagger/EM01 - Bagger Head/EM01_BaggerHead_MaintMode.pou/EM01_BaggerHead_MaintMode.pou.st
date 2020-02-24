(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK EM01_BaggerHead_MaintMode EXTENDS FB_PackMLStates
VAR_INPUT
	
END_VAR
VAR_OUTPUT
	state : HEAD_STATES;
    sealAndSeparateSubState : SEAL_SEPARATE_STATES;
    releaseAndFeedSubState : RELEASE_FEED_STATES;
    openBagSubState : BAG_OPEN_ASSIST_STATES;
END_VAR
VAR
	_beginCycleFromInfeeed : BOOL;
	_readyToAcceptProduct : BOOL;
	cycleTimer : TON() := (PT := T#1000S);
	cycleTime : REAL;
	bagOpenRetryCount : UINT;
	bagOpenRetrySetting : UINT := 3;
END_VAR
VAR_IN_OUT
	//modeManager : PACK_ML.UnitModeManager;
	bagger : EM01_BaggerHead;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: EM01_Bagger_Automode
//	Description: This is an implementation of a bagger in Auto Mode (normal operation) using the PackML standard.
//				 Each method is a PackML state.
//	Created by: Ben Hess
//	Created Date: Tuesday, March 26, 2019