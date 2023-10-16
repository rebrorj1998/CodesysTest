(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Halt
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF state = eDualMotorPressureBar_AsyncStates.Idle THEN
	MC_HomeFrontMotor.execute := FALSE;
	MC_MoveFrontMotorABS.execute := FALSE;
	MC_MoveFrontMotorPush.execute := FALSE;
	MC_ResetFrontMotor.execute := FALSE;
 	//MC_HaltFrontMotor.execute := TRUE;
	_timeoutTimer.IN := FALSE;
END_IF

