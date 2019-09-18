

FUNCTION_BLOCK FB_TempController EXTENDS BaseComponentFB
VAR_INPUT
	temperatureSensor : ITempSensor;
	temperatureSetpoint : REAL;
END_VAR
VAR_OUTPUT
	heaterPulse : BOOL;
	currentTemp : REAL;
	thermalRunawayOvershoot : FB_Fault(name := 'Thermal Runaway - Overshoot');
	thermalRunawayNotHeating : FB_Fault(name := 'Thermal Runaway - Not Heating');
	tempOK : BOOL; // At desired temperature
	cooling : BOOL; // Cooling down to setpoint temp
	heating : BOOL; // Heating up to setpoint temp
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
	lastTemp : REAL;
	thermRunawayNHUpdateTimer : Standard.TON := (PT := T#30S);
	thermRunawayNHFaultTimer : Standard.TON := (PT := T#31S);
	thermRunawayOSUpdateTimer : Standard.TON := (PT := T#30S);
	thermRunawayOSFaultTimer : Standard.TON := (PT := T#31S);
END_VAR

SUPER^();
IF enableONS.Q THEN
	lastTemp := currentTemp;
END_IF
updateTimer(IN := NOT updateTimer.Q);
thermRunawayNHUpdateTimer();
thermRunawayNHFaultTimer();
thermRunawayOSUpdateTimer();
thermRunawayOSFaultTimer();

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
cooling := (enable AND temperatureSensor.TempReadingF > temperatureSetpoint) OR NOT enable;
heating := enable AND temperatureSensor.TempReadingF < temperatureSetpoint;
diffScaled := TO_DINT((PI.DIFF * 1000));

currentTemp := temperatureSensor.TempReadingF;
tempScaled := TO_DINT((temperatureSensor.TempReadingF * 1000));

PWM(
	CI:= PI.Y / 1000, 
	MAN_IN:= , 
	MANUAL:= , 
	F:= _pwmHz , 
	Q=> heaterPulse);
	
IF NOT enable OR REAL_TO_INT(temperatureSensor.TempReadingC) = 0 THEN
	_manualMode := TRUE;
	_manualOutput := 0.0;
ELSE
	_manualMode := FALSE;
END_IF

// Thermal Runaway - not heating
IF (NOT tempOK AND heating) AND NOT thermalRunawayNotHeating.active THEN
	thermRunawayNHUpdateTimer.IN := TRUE;
	IF thermRunawayNHUpdateTimer.Q THEN
		IF TO_DINT(currentTemp) > TO_DINT(lastTemp) THEN
			thermRunawayNHFaultTimer.IN := FALSE;
		ELSE
			thermRunawayNHFaultTimer.IN := TRUE;
		END_IF
		lastTemp := currentTemp; 
		thermRunawayNHUpdateTimer.IN := FALSE;
	END_IF	
ELSE
	thermRunawayNHUpdateTimer.IN := FALSE;
END_IF

IF thermRunawayNHFaultTimer.Q THEN
	thermalRunawayNotHeating.Trigger();
	thermRunawayNHFaultTimer.IN := FALSE;
END_IF

// Thermal Runaway - overshoot
IF (NOT tempOK AND cooling) AND NOT thermalRunawayOvershoot.active THEN
	thermRunawayOSUpdateTimer.IN := TRUE;
	IF thermRunawayOSUpdateTimer.Q THEN
		IF TO_DINT(currentTemp) < TO_DINT(lastTemp) THEN
			thermRunawayOSFaultTimer.IN := FALSE;
		ELSE
			thermRunawayOSFaultTimer.IN := TRUE;
		END_IF
		lastTemp := currentTemp; 
		thermRunawayOSUpdateTimer.IN := FALSE;
	END_IF	
ELSE
	thermRunawayOSUpdateTimer.IN := FALSE;
END_IF

IF thermRunawayOSFaultTimer.Q THEN
	thermalRunawayOvershoot.Trigger();
	thermRunawayOSFaultTimer.IN := FALSE;
END_IF


IF currentTemp < (temperatureSetpoint - 10) OR currentTemp > (temperatureSetpoint + 10) THEN
	HMIData.sealBarNotAtTemperature.active := TRUE;
	tempOK := FALSE;
ELSE
	HMIData.sealBarNotAtTemperature.active := FALSE;
	tempOK := TRUE;
	lastTemp := currentTemp;
END_IF