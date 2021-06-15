(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_MurrK50_AdvancedMode
VAR_INPUT
	IOLinkData : POINTER TO ARRAY[0..9] OF BYTE;
	baggerReady : BOOL;
	baggerFaulted : BOOL;
	baggerInCycle : BOOL;
	baggerExternalInhibited : BOOL;
END_VAR
VAR
	_IOLinkStateOutput : BYTE;
	_IOLinkData : ARRAY[0..9] OF BYTE;
	_baggerNotReadyProfile : K50OutputProfile := 
		(animationType := K50AnimationTypes.Off,
  dynamicSequenceValue := 0);
  
  	_baggerReadyProfile : K50OutputProfile := 
			 (colorOne := K50Colors.Green,
              colorTwo := K50Colors.Green,
         animationType := K50AnimationTypes.Steady,
  dynamicSequenceValue := 0);
  
  	_baggerInCycleProfile : K50OutputProfile := 
			 (colorOne := K50Colors.Green,
              colorTwo := K50Colors.White,
         animationType := K50AnimationTypes.fiftyfiftyRotate,
        animationSpeed := K50AnimationSpeeds.Medium,
    animationDirection := K50AnimationDirection.CCW,
     animationPatterns := K50AnimationPatterns.Flash,
  dynamicSequenceValue := 0);
  
    	_baggerInhibitedProfile : K50OutputProfile := 
			 (colorOne := K50Colors.White,
              colorTwo := K50Colors.Orange,
         animationType := K50AnimationTypes.Chase,
        animationSpeed := K50AnimationSpeeds.Medium,
    animationDirection := K50AnimationDirection.CCW,
     animationPatterns := K50AnimationPatterns.Flash,
  dynamicSequenceValue := 0);
  
  	_baggerFaultedProfile : K50OutputProfile := 
			 (colorOne := K50Colors.Red,
              colorTwo := K50Colors.Red,
         animationType := K50AnimationTypes.Flash,
        animationSpeed := K50AnimationSpeeds.Medium,
    animationDirection := K50AnimationDirection.CCW,
     animationPatterns := K50AnimationPatterns.Flash,
  dynamicSequenceValue := 0);
  
  	_profiles : ARRAY[0..4] OF K50OutputProfile := [_baggerNotReadyProfile, 
													_baggerReadyProfile, 
													_baggerInCycleProfile, 
													_baggerInhibitedProfile, 
													_baggerFaultedProfile];
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

//
_IOLinkStateOutput := 0;
IF baggerReady THEN
	_IOLinkStateOutput := 1;
END_IF
IF baggerInCycle THEN
	_IOLinkStateOutput := 2;
END_IF
IF baggerExternalInhibited THEN
	_IOLinkStateOutput := 3;
END_IF
IF baggerFaulted THEN
	_IOLinkStateOutput := 4;
END_IF

// Write The Selected Profiles Data To The Correct IO-Link Bytes
_IOLinkData[0] := _profiles[_IOLinkStateOutput].colorTwo;
_IOLinkData[1] := _profiles[_IOLinkStateOutput].colorOne;
_IOLinkData[3] := _profiles[_IOLinkStateOutput].dynamicSequenceValue;
_IOLinkData[6].0 := _profiles[_IOLinkStateOutput].animationSpeed.0;
_IOLinkData[6].1 := _profiles[_IOLinkStateOutput].animationSpeed.1;
_IOLinkData[6].2 := _profiles[_IOLinkStateOutput].vibrationFeedback.0;
_IOLinkData[6].3 := _profiles[_IOLinkStateOutput].vibrationFeedback.1;
_IOLinkData[7].0 := _profiles[_IOLinkStateOutput].animationType.0;
_IOLinkData[7].1 := _profiles[_IOLinkStateOutput].animationType.1; 
_IOLinkData[7].2 := _profiles[_IOLinkStateOutput].animationType.2;
_IOLinkData[7].3 := _profiles[_IOLinkStateOutput].animationType.3;
_IOLinkData[7].4 := _profiles[_IOLinkStateOutput].animationDirection.0;
_IOLinkData[7].5 := _profiles[_IOLinkStateOutput].animationPatterns.0; 
_IOLinkData[7].6 := _profiles[_IOLinkStateOutput].animationPatterns.1;
_IOLinkData[7].7 := _profiles[_IOLinkStateOutput].animationPatterns.2;
IOLinkData^ := _IOLinkData;