

FUNCTION_BLOCK FB_IFMTempSensor EXTENDS FB_TemperatureSensor
VAR_INPUT
	ptrTemperatureBytes : POINTER TO ARRAY[0..1] OF BYTE; 
END_VAR
VAR_OUTPUT
	rtdFailure : FB_Fault(name := 'RTD Failure');
END_VAR
VAR
END_VAR

//	Function Block: FB_IFMTempSensor
//	Description: Implemention of an IFM TP3232 IOLink temperature sensor
//	
//	Created by: Ben Hess
//	Created Date: Tuesday, September 11, 2018


METHOD Execute
VAR_INPUT
END_VAR

_rawTemperatureReading := TO_INT(OSCAT_BASIC.WORD_OF_BYTE(B0 := ptrTemperatureBytes^[1], B1 := ptrTemperatureBytes^[0])); 
_temperatureReadingC := TO_REAL(_rawTemperatureReading / 10.0);
_temperatureReadingF := OSCAT_BASIC.C_TO_F(_temperatureReadingC);

IF _rawTemperatureReading = 0 AND Globals.machinePowerOK THEN 
	rtdFailure.Trigger();
END_IF