(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Jog
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
	IF _jogForwardONS.OSR THEN
			_bagFeedFrontMotor.jog := TRUE;
			_bagFeedFrontMotor.MoveDistance(
				distance := 30, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((1 * velocityMultiplier))
			);
			_bagFeedRearMotor.jog := TRUE;
			_bagFeedRearMotor.MoveDistance(
				distance := 30, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((1 * velocityMultiplier))
			);										
		ELSIF _jogReverseONS.OSR THEN
			_bagFeedFrontMotor.jog := TRUE;
			_bagFeedFrontMotor.MoveDistance(
				distance := -30, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((1 * velocityMultiplier))
			);
			_bagFeedRearMotor.jog := TRUE;
			_bagFeedRearMotor.MoveDistance(
				distance := -30, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((1 * velocityMultiplier))
			);
		ELSIF _jogForwardONS.OSF OR _jogReverseONS.OSF THEN
			_bagFeedFrontMotor.Stop();
			_bagFeedFrontMotor.jog := FALSE;
			_bagFeedRearMotor.Stop();
			_bagFeedRearMotor.jog := FALSE;
		END_IF