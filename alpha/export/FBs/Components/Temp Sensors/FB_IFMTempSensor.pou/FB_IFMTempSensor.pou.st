(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_IFMTempSensor EXTENDS FB_TemperatureSensor
VAR_INPUT
	ptrTemperatureBytes : POINTER TO ARRAY[0..1] OF BYTE; 
END_VAR
VAR_OUTPUT
	rtdFailure : FB_Fault(name := 'RTD Failure');
END_VAR
VAR
	_dataInitalizingDelayTimer : TON := (PT := T#3S);
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_IFMTempSensor
//	Description: Implemention of an IFM TP3232 IOLink temperature sensor
//	
//	Created by: Ben Hess
//	Created Date: Tuesday, September 11, 2018
