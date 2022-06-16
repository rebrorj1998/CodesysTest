(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Jog
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
	IF _jogForwardONS.OSR THEN
			_jogging := TRUE;
			_bagFeedFrontMotor.MoveDistance(
				distance := 30, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((1 * velocityMultiplier))
			);
			_bagFeedRearMotor.MoveDistance(
				distance := 30, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((1 * velocityMultiplier))
			);										
		ELSIF _jogReverseONS.OSR THEN
			_jogging := TRUE;
			_bagFeedFrontMotor.MoveDistance(
				distance := -30, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((1 * velocityMultiplier))
			);
			_bagFeedRearMotor.MoveDistance(
				distance := -30, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((1 * velocityMultiplier))
			);
		ELSIF _jogForwardONS.OSF OR _jogReverseONS.OSF THEN
			_jogging := FALSE;
			_bagFeedFrontMotor.Stop();
			_bagFeedRearMotor.Stop();
		END_IF