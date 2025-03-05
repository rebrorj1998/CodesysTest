(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD DetermineOutSetpoint : real
VAR_INPUT
	bagWidth : REAL;
	machineModel : ModelSelection;
END_VAR
VAR_OUTPUT
	setpoint : REAL := 0;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF bagWidth >= 0 AND bagWidth <= 5 THEN
	IF (machineModel = modelSelection.Pro18_1174 OR machineModel = modelSelection.Pro18_1183) THEN
		setpoint := 1;
	ELSE
		setpoint := 11;
	END_IF
	RETURN;
ELSIF bagWidth > 5 AND bagWidth <= 10 THEN
	IF (machineModel = modelSelection.Pro18_1174 OR machineModel = modelSelection.Pro18_1183) THEN
		setpoint := 2;
	ELSE
		setpoint := 12;
	END_IF
	RETURN;	
ELSIF bagWidth > 10 AND bagWidth <= 15 THEN
	IF (machineModel = modelSelection.Pro18_1174 OR machineModel = modelSelection.Pro18_1183) THEN
		setpoint := 3;
	ELSE
		setpoint := 13;
	END_IF
	RETURN;
ELSIF bagWidth > 15 AND bagWidth <= 25 THEN
	IF (machineModel = modelSelection.Pro18_1174 OR machineModel = modelSelection.Pro18_1183) THEN
		setpoint := 4;
	ELSE
		setpoint := 14;
	END_IF
	RETURN;
END_IF