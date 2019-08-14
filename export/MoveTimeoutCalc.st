

FUNCTION MoveTimeoutCalc : TIME
VAR_INPUT
	distance : REAL;
	velo : REAL;
	buffer : REAL;		// Buffer time to add for timeout
END_VAR
VAR
END_VAR

MoveTimeoutCalc := TO_TIME(((ABS(distance) / velo) * 1000) + buffer);

FUNCTION MoveTimeoutCalc : TIME
VAR_INPUT
	distance : REAL;
	velo : REAL;
	buffer : REAL;		// Buffer time to add for timeout
END_VAR
VAR
END_VAR

MoveTimeoutCalc := TO_TIME(((ABS(distance) / velo) * 1000) + buffer);