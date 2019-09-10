

FUNCTION_BLOCK FB_TemperatureSensor IMPLEMENTS ITempSensor
VAR_INPUT
END_VAR
VAR_OUTPUT
END_VAR
VAR
	_instanceName : STRING;			// Instance Name
	_rawTemperatureReading : INT;   // Raw reading from sensor
	_temperatureReadingC : REAL;	// Scaled temperaure reading in degC
	_temperatureReadingF : REAL;	// Scaled temperaure reading in degF
END_VAR



{attribute 'monitoring' := 'variable'}
PROPERTY TempReadingC : REAL


{attribute 'monitoring' := 'variable'}
PROPERTY TempReadingF : REAL


{attribute 'monitoring' := 'variable'}
PROPERTY InstanceName : STRING