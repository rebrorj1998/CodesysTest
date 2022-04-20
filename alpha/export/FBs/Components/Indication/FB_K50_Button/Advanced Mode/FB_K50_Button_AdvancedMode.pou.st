(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_K50_Button_AdvancedMode
VAR_INPUT
	IOLinkData : POINTER TO ARRAY[0..9] OF BYTE;
	baggerReady : BOOL;
	baggerFaulted : BOOL;
	baggerInCycle : BOOL;
	baggerExternalInhibited : BOOL;
	baggerHeatingUp : BOOL;
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
			 (colorOne := K50Colors.Yellow,
              colorTwo := K50Colors.White,
         animationType := K50AnimationTypes.fiftyfiftyRotate,
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
  
	_heatingUpProfile : K50OutputProfile := 
			 (colorOne := K50Colors.Orange,
              colorTwo := K50Colors.Amber,
         animationType := K50AnimationTypes.fiftyfiftyRotate,
        animationSpeed := K50AnimationSpeeds.Slow,
    animationDirection := K50AnimationDirection.CCW,
     animationPatterns := K50AnimationPatterns.Flash,
  dynamicSequenceValue := 0);  
  	_profiles : ARRAY[0..5] OF K50OutputProfile := [_baggerNotReadyProfile, 
													_baggerReadyProfile, 
													_baggerInCycleProfile, 
													_baggerInhibitedProfile, 
													_baggerFaultedProfile,
													_heatingUpProfile];
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//
//  FB_MurrK50_AdvancedMode
//  FBs/Indication/FB_K50_Button/Advanced Mode/FB_K50_Button_AdvancedMode
//
//  Created by Evan Ische on 6/17/2021. 
//  Copyright (C) 2021 Sharp Packaging Systems By Pregis. All rights reserved.
//

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
IF baggerHeatingUp THEN
	_IOLinkStateOutput := 5;
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