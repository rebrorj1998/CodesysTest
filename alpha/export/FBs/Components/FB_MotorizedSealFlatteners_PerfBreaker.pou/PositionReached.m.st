(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD PositionReached : BOOL
VAR_INPUT
	currentPosition 	: REAL ;
	positionSetpoint	: REAL ;
	tolerance 			: REAL 		:= 0.125 ;
END_VAR
VAR_STAT
	overShootTRM		: TON ;
	overShootDuration	: TIME		:= T#20MS ;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
overShootTRM( PT := overShootDuration );

IF ABS( currentPosition - positionSetpoint ) < tolerance THEN
	overShootTRM.IN := TRUE;
	IF overShootTRM.Q THEN
		PositionReached := TRUE;
	END_IF
ELSE
	overShootTRM.IN := FALSE;
END_IF