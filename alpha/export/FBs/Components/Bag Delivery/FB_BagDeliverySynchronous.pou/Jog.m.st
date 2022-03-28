(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Jog
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
	IF jogForwardONS.OSR THEN
			bagFeedMasterMotor.MoveDistance(
				distance := 30, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((1 * velocityMultiplier))
			);
			bagFeedRearMotor.MoveDistance(
				distance := 30, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((1 * velocityMultiplier))
			);										
		ELSIF jogReverseONS.OSR THEN
			bagFeedMasterMotor.MoveDistance(
				distance := -30, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((1 * velocityMultiplier))
			);
			bagFeedRearMotor.MoveDistance(
				distance := -30, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((1 * velocityMultiplier))
			);
		ELSIF jogForwardONS.OSF OR jogReverseONS.OSF THEN
			bagFeedMasterMotor.Stop();
			bagFeedRearMotor.Stop();
		END_IF