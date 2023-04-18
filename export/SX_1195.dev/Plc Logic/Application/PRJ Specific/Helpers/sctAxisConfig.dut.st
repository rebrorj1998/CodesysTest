(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE sctAxisConfig :
STRUCT
	zeroOffset : REAL;
	stepsPerInch : REAL;    
	rotationsPerInch : REAL;   
	reversePolarity : BOOL; 
	defaultCurrent : REAL;  
END_STRUCT
END_TYPE
