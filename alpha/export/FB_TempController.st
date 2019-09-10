

FUNCTION_BLOCK FB_TempController EXTENDS BaseComponentFB
VAR_INPUT
	temperatureSensor : ITempSensor;
	temperatureSetpoint : REAL;
END_VAR
VAR_OUTPUT
	heaterPulse : BOOL;
	currentTemp : REAL;
	thermalRunaway : FB_Fault(name := 'Thermal Runaway');
END_VAR
VAR
	_manualOutput : REAL;
	_manualMode : BOOL;
	_kp : REAL := 150;
	_ki : REAL := 2;
	_ll : REAL := 0;
	_lh : REAL := 1000;
	_deadBand : REAL := 1;
	_pwmHz : REAL := 1;
	updateTimer : TON := (PT := T#100ms);
	PI : OSCAT_BASIC.CTRL_PI;	
	PWM : OSCAT_BASIC.CTRL_PWM;
	tempScaled : DINT;
	diffScaled : DINT;
	diffLast : DINT;
	thermalRunawayUpdateTimer : Standard.TON := (PT := T#1S);;
	thermalRunawayTimer : Standard.TON := (PT := T#10S);;
END_VAR

updateTimer(IN := NOT updateTimer.Q);
thermalRunawayUpdateTimer(IN := NOT thermalRunawayUpdateTimer.Q, PT := T#1S);
thermalRunawayTimer();
IF updateTimer.Q THEN
	PI(
		ACT:= temperatureSensor.TempReadingF, 
		SET:= temperatureSetpoint, 
		SUP:= _deadBand, 
		OFS:= , 
		M_I:= _manualOutput, 
		MAN:= _manualMode, 
		RST:= , 
		KP:= _kp, 
		KI:= _ki, 
		LL:= _ll, 
		LH:= _lh, 
		Y=> , 
		DIFF=> , 
		LIM=> );
END_IF

diffScaled := TO_DINT((PI.DIFF * 1000));
currentTemp := temperatureSensor.TempReadingF;
tempScaled := TO_DINT((temperatureSensor.TempReadingF * 1000));

PWM(
	CI:= PI.Y / 1000, 
	MAN_IN:= , 
	MANUAL:= , 
	F:= _pwmHz , 
	Q=> heaterPulse);
	
IF NOT enable OR REAL_TO_INT(temperatureSensor.TempReadingC) = 0 OR thermalRunaway.active THEN
	_manualMode := TRUE;
	_manualOutput := 0.0;
ELSE
	_manualMode := FALSE;
END_IF

IF enable AND thermalRunawayUpdateTimer.Q THEN
	IF PI.Y > 0 THEN
		IF diffScaled > diffLast  THEN
			thermalRunawayTimer.IN := TRUE;
		ELSE	
			thermalRunawayTimer.IN := FALSE;
		END_IF	
		diffLast := diffScaled;
	END_IF
END_IF

IF currentTemp < (temperatureSetpoint - 10) OR currentTemp > (temperatureSetpoint + 10) THEN
	HMIData.sealBarNotAtTemperature.active := TRUE;
ELSE
	HMIData.sealBarNotAtTemperature.active := FALSE;
END_IF