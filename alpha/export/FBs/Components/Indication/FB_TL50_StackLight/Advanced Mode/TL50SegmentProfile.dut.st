(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE TL50SegmentProfile :
STRUCT
	colorOne : TL50Colors;
	colorOneIntensity : TL50Intensity;
	animationType : TL50AnimationTypes;
	animationSpeed : TL50AnimationSpeeds;
	animationPattern : TL50AnimationPatterns;
	colorTwo : TL50Colors;
	colorTwoIntensity : TL50Intensity;
	animationDirection : TL50AnimationDirection;
	audibleState : TL50AudibleStates;
END_STRUCT
END_TYPE
