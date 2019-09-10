

FUNCTION_BLOCK FB_DriveTemp EXTENDS FB_PredictiveMaint
VAR_INPUT
	iDriveTemp : DINT;
	maxTemp : REAL;
END_VAR
VAR_OUTPUT
	DriveTemp : REAL;
END_VAR
VAR
END_VAR

DriveTemp := TO_REAL(iDriveTemp) / 10.0;