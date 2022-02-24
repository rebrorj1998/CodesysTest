(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Execute
VAR_INPUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)

// Wait a predetermined amount of time before looking at faults.
_dataInitalizingDelayTimer(
	IN := Globals.machinePowerOK 
);

//
_rawTemperatureReading := TO_INT(OSCAT_BASIC.WORD_OF_BYTE(B0 := ptrTemperatureBytes^[1], B1 := ptrTemperatureBytes^[0])); 
_temperatureReadingC := TO_REAL(_rawTemperatureReading / 10.0);
_temperatureReadingF := OSCAT_BASIC.C_TO_F(_temperatureReadingC);

//
IF _rawTemperatureReading = 0 AND _dataInitalizingDelayTimer.Q THEN 
	rtdFailure.Trigger();
END_IF