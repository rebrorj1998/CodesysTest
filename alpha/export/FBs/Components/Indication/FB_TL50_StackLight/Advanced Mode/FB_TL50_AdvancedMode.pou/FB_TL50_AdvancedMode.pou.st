(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_TL50_AdvancedMode
VAR_INPUT
	IOLinkData : POINTER TO ARRAY[0..30] OF BYTE;
	baggerReady : BOOL;
	baggerFaulted : BOOL;
	baggerInCycle : BOOL;
	baggerExternalInhibited : BOOL;
	bagsLow : BOOL;
	bagOpenRetryActive : BOOL;
	
	baggerFaultSegment : INT := TL50Segments.Top;
	baggerStatusSegment : INT := TL50Segments.SecondDown;
	baggerBagsLowSegment : INT := TL50Segments.ThridDown;
	bagOpenRetrySegment : INT := TL50Segments.Bottom;
END_VAR
VAR
	_IOLinkStateOutput : BYTE;
	_IOLinkData : ARRAY[0..30] OF BYTE;
	
	_segmentOffProfile : TL50SegmentProfile := (
	colorOne:= 0, 			 
	colorOneIntensity:= TL50Intensity.Off, 
	animationType:= 0, 
	animationSpeed:= 0, 
	animationPattern:= 0, 
	colorTwo:= 0, 
	colorTwoIntensity:= TL50Intensity.Off, 
	animationDirection:= 0,
	audibleState := TL50AudibleStates.Off);
	
  	_baggerReadyProfile : TL50SegmentProfile := (
	colorOne:= TL50Colors.Green, 
	colorOneIntensity:= TL50Intensity.High, 
	animationType:= TL50AnimationTypes.Flash, 
	//animationSpeed:= , 
	//animationPattern:= , 
	//colorTwo:= , 
	colorTwoIntensity:= TL50Intensity.Off, 
	//animationDirection:= ,
	audibleState := TL50AudibleStates.Off);
	
  _baggerInCycleProfile : TL50SegmentProfile := (
	colorOne:= TL50Colors.Green, 
	colorOneIntensity:= TL50Intensity.High, 
	animationType:= TL50AnimationTypes.Steady, 
	//animationSpeed:= , 
	//animationPattern:= , 
	//colorTwo:= , 
	colorTwoIntensity:= TL50Intensity.Off, 
	//animationDirection:= ,
	audibleState := TL50AudibleStates.Off);
	
  _baggerInhibitedProfile : TL50SegmentProfile := (
	colorOne:= TL50Colors.Yellow, 
	colorOneIntensity:= TL50Intensity.High, 
	animationType:= TL50AnimationTypes.fiftyfiftyRotate, 
	animationSpeed:= K50AnimationSpeeds.Medium, 
	animationPattern:= K50AnimationPatterns.Flash, 
	colorTwo:= K50Colors.White, 
	colorTwoIntensity:= TL50Intensity.High, 
	animationDirection:= K50AnimationDirection.CCW ,
	audibleState := TL50AudibleStates.Off);
 
  _baggerFaultedProfile : TL50SegmentProfile := (
	colorOne:= TL50Colors.Red, 
	colorOneIntensity:= TL50Intensity.High, 
	animationType:= TL50AnimationTypes.Flash, 
	animationSpeed:= TL50AnimationSpeeds.Medium, 
	//animationPattern:= , 
	//colorTwo:= , 
	colorTwoIntensity:= TL50Intensity.Off, 
	//animationDirection:= ,
	audibleState := TL50AudibleStates.Off);
	
  _bagsLowProfile : TL50SegmentProfile := (
	colorOne:= TL50Colors.Orange, 
	colorOneIntensity:= TL50Intensity.High, 
	animationType:= TL50AnimationTypes.Flash, 
	animationSpeed:= TL50AnimationSpeeds.Medium, 
	//animationPattern:= , 
	//colorTwo:= , 
	colorTwoIntensity:= TL50Intensity.Off, 
	//animationDirection:= ,
	audibleState := TL50AudibleStates.Off);
	
	_bagOpenRetryActiveProfile : TL50SegmentProfile := (
	colorOne:= TL50Colors.Orange, 
	colorOneIntensity:= TL50Intensity.High, 
	animationType:= TL50AnimationTypes.Flash, 
	animationSpeed:= TL50AnimationSpeeds.Fast, 
	//animationPattern:= , 
	//colorTwo:= , 
	colorTwoIntensity:= TL50Intensity.Off, 
	//animationDirection:= ,
	audibleState := TL50AudibleStates.Off);
	
  	_segments : ARRAY[1..4] OF TL50SegmentProfile;  //1 = bottom segment, 4 = top. Using "from 1" to match Banner documentation
	i : INT;
	IOLinkIndexByte : INT;
END_VAR
VAR CONSTANT
	SIZE_OF_IOLINK_DATA : INT := 31;  	// Total size in bytes of IOLink Image
	SIZE_OF_SEGMENT_DATA : INT := 3;		// Size in bytes of each light segment in IOLink Image
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//
//  FB_TL50_AdvancedMode
//  FBs/Indication/FB_TL50_StackLight/Advanced Mode/FB_TL50_AdvancedMode
//
//  Created by Ben Hess on 4/18/2021. 
//  Copyright (C) 2022 Sharp Packaging Systems By Pregis. All rights reserved.
//

//  IOLink Stack Light by Banner. Assumes 4 segments


// Set all segments to zero and then only set those that are active
ClearSegments();
IF baggerReady THEN
	_segments[baggerStatusSegment] := _baggerReadyProfile;
END_IF
IF baggerInCycle THEN
	_segments[baggerStatusSegment] := _baggerInCycleProfile;
END_IF
IF baggerExternalInhibited THEN
	_segments[baggerStatusSegment] := _baggerInhibitedProfile;
END_IF
IF baggerFaulted THEN
	_segments[baggerFaultSegment] := _baggerFaultedProfile;
END_IF
IF bagsLow THEN
	_segments[baggerBagsLowSegment] := _bagsLowProfile;
END_IF
IF bagOpenRetryActive THEN
	_segments[bagOpenRetrySegment] := _bagOpenRetryActiveProfile;
END_IF


// Audible State only triggered by fault segment for now
_IOLinkData[0] := _segments[baggerFaultSegment].audibleState;

// Pack The Selected Profiles Data To The Correct IO-Link Bytes //
// Iterate through all 4 segments
FOR i := TL50Segments.Top TO TL50Segments.Bottom BY -1 DO
	IOLinkIndexByte := (SIZE_OF_IOLINK_DATA - (i * SIZE_OF_SEGMENT_DATA));
	// Segment Byte 0 
	_IOLinkData[IOLinkIndexByte].0 := _segments[i].colorTwo.0;
	_IOLinkData[IOLinkIndexByte].1 := _segments[i].colorTwo.1;
	_IOLinkData[IOLinkIndexByte].2 := _segments[i].colorTwo.2;
	_IOLinkData[IOLinkIndexByte].3 := _segments[i].colorTwo.3;
	_IOLinkData[IOLinkIndexByte].4 := _segments[i].colorTwoIntensity.0;
	_IOLinkData[IOLinkIndexByte].5 := _segments[i].colorTwoIntensity.1;
	_IOLinkData[IOLinkIndexByte].6 := _segments[i].colorTwoIntensity.2;
	_IOLinkData[IOLinkIndexByte].7 := _segments[i].animationDirection.0;
	// Segment Byte 1
	_IOLinkData[IOLinkIndexByte + 1].0 := _segments[i].animationType.0;
	_IOLinkData[IOLinkIndexByte + 1].1 := _segments[i].animationType.1;
	_IOLinkData[IOLinkIndexByte + 1].2 := _segments[i].animationType.2;
	_IOLinkData[IOLinkIndexByte + 1].3 := _segments[i].animationSpeed.0;
	_IOLinkData[IOLinkIndexByte + 1].4 := _segments[i].animationSpeed.1;
	_IOLinkData[IOLinkIndexByte + 1].5 := _segments[i].animationPattern.0;
	_IOLinkData[IOLinkIndexByte + 1].6 := _segments[i].animationPattern.1;
	_IOLinkData[IOLinkIndexByte + 1].7 := _segments[i].animationPattern.2;
	// Segment Byte 2
	_IOLinkData[IOLinkIndexByte + 2].0 := _segments[i].colorOne.0;
	_IOLinkData[IOLinkIndexByte + 2].1 := _segments[i].colorOne.1;
	_IOLinkData[IOLinkIndexByte + 2].2 := _segments[i].colorOne.2;
	_IOLinkData[IOLinkIndexByte + 2].3 := _segments[i].colorOne.3;
	_IOLinkData[IOLinkIndexByte + 2].4 := _segments[i].colorOneIntensity.0;
	_IOLinkData[IOLinkIndexByte + 2].5 := _segments[i].colorOneIntensity.1;
	_IOLinkData[IOLinkIndexByte + 2].6 := _segments[i].colorOneIntensity.2;
	_IOLinkData[IOLinkIndexByte + 2].7 := _segments[i].animationDirection.0;
END_FOR

// SEND IT!
IOLinkData^ := _IOLinkData;