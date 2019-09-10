

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

IF _blinkFast THEN
	blinker.F := fastBlinkSec;
ELSIF _blinkSlow THEN 
	blinker.F := slowBlinkSec;
END_IF
	
blinker(F:= , DC:= , Q=> );

lightOutput := _turnOn OR (blinker.Q AND (_blinkFast OR _blinkSlow));




METHOD BlinkSlow
VAR_INPUT
END_VAR

_blinkFast := FALSE;
_blinkSlow := TRUE;
_turnOn := FALSE;

METHOD BlinkFast
VAR_INPUT
END_VAR

_blinkFast := TRUE;
_blinkSlow := FALSE;
_turnOn := FALSE;

METHOD TurnOff
VAR_INPUT
END_VAR

_blinkFast := FALSE;
_blinkSlow := FALSE;
_turnOn := FALSE;

METHOD TurnOn
VAR_INPUT
END_VAR

_blinkFast := FALSE;
_blinkSlow := FALSE;
_turnOn := TRUE;