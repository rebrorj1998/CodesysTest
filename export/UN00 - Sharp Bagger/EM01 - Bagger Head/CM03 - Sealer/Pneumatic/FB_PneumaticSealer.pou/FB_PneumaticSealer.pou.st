(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FINAL FB_PneumaticSealer EXTENDS FB_BasicSealer
VAR_INPUT
	cylinder : ICylinder;
END_VAR
VAR_OUTPUT
END_VAR
VAR

END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
SUPER^();


EnableSimulation(cylinder,simulateIO);


IF sealActive THEN
	cylinder.Extend();
ELSE
	cylinder.Retract();
END_IF