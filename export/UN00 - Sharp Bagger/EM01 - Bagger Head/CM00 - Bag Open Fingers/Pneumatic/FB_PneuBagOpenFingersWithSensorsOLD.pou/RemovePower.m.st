(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD RemovePower
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^.RemovePower();

// Try to exhaust the BOF actuators, if the solenoid valve doesn't have that ability then move the fingers up
IF NOT ExhaustIfPossible(fingerActuators) THEN
	fingerActuators.MoveUp();
END_IF