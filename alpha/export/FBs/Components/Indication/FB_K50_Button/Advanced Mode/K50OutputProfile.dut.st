(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE K50OutputProfile :
STRUCT
	colorOne : K50Colors;
	colorTwo : K50Colors;
	animationType : K50AnimationTypes;
	animationSpeed : K50AnimationSpeeds;
	animationDirection : K50AnimationDirection;
	animationPatterns : K50AnimationPatterns;
	vibrationFeedback : K50VibrationFeedback := K50VibrationFeedback.On;
	dynamicSequenceValue : BYTE;
END_STRUCT
END_TYPE
