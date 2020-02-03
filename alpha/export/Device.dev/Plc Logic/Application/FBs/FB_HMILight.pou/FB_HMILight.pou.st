(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_HMILight
VAR_INPUT
END_VAR
VAR_OUTPUT
	lightOutput : BOOL;
END_VAR
VAR
	_turnOn : BOOL;
	_blinkFast : BOOL;
	_blinkSlow : BOOL;
	blinker : OSCAT_BASIC.PWM_DC := (F := 1, DC := 0.5);
	slowBlinkSec : REAL := 1;
	fastBlinkSec : REAL := 0.5;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
IF _blinkFast THEN
	blinker.F := fastBlinkSec;
ELSIF _blinkSlow THEN 
	blinker.F := slowBlinkSec;
END_IF
	
blinker(F:= , DC:= , Q=> );

lightOutput := _turnOn OR (blinker.Q AND (_blinkFast OR _blinkSlow));


