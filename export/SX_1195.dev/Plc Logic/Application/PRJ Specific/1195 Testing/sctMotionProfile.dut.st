(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE sctMotionProfile :
STRUCT
	velocity : REAL;
	acceleration : REAL;
	deceleration : REAL;
	position : REAL;
	minPosition : REAL;
	maxPosition : REAL;
	current : REAL;
END_STRUCT
END_TYPE
