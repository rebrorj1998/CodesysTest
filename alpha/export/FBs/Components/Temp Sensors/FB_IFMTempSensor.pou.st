(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_IFMTempSensor EXTENDS FB_TemperatureSensor
VAR_INPUT
	busNodeOK : BOOL;
	ptrTemperatureBytes : POINTER TO ARRAY[0..1] OF BYTE; 
END_VAR
VAR_OUTPUT
	reconfigureIO : BOOL;
	rtdFailure : FB_Fault(name := 'RTD Failure');
END_VAR
VAR
	_reconfigured : BOOL;
	_state : TEMP_SENSOR_STATES;
	_reconfigureONS : Standard.R_TRIG;
	_dataInitalizingDelayTimer : TON := (PT := T#3S);
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_IFMTempSensor
//	Description: Implemention of an IFM TP3232 IOLink temperature sensor
//	
//	Created by: Ben Hess
//	Created Date: Tuesday, September 11, 2018

//
_rawTemperatureReading := TO_INT(OSCAT_BASIC.WORD_OF_BYTE(B0 := ptrTemperatureBytes^[1], B1 := ptrTemperatureBytes^[0])); 
_temperatureReadingC := TO_REAL(_rawTemperatureReading / 10.0);
_temperatureReadingF := OSCAT_BASIC.C_TO_F(_temperatureReadingC);

//
_dataInitalizingDelayTimer();

//
CASE _state OF
	TEMP_SENSOR_STATES.Idle:
		IF busNodeOK AND _rawTemperatureReading = 0 THEN
			IF _reconfigured THEN
				rtdFailure.Trigger();
			ELSE
				_state := TEMP_SENSOR_STATES.ReconfigureIO;
			END_IF
		END_IF
	TEMP_SENSOR_STATES.ReconfigureIO:
		reconfigureIO := TRUE;
		_state := TEMP_SENSOR_STATES.ReconfiguringIO;
	TEMP_SENSOR_STATES.ReconfiguringIO:
		reconfigureIO := FALSE;
		IF busNodeOK THEN
			_state := TEMP_SENSOR_STATES.ReconfiguredIO;
		END_IF
	TEMP_SENSOR_STATES.ReconfiguredIO:
		// Wait a predetermined amount of time before looking at faults.
		_reconfigured := TRUE;
		_dataInitalizingDelayTimer.IN := TRUE;
		IF _dataInitalizingDelayTimer.Q THEN 
			IF _rawTemperatureReading = 0 THEN
				rtdFailure.Trigger();
			END_IF
			_state := TEMP_SENSOR_STATES.Idle;
		END_IF
END_CASE
