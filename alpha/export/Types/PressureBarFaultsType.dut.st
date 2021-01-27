(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE PressureBarFaultsType :
STRUCT
	failedToOpen : FB_Fault(name := 'Pressure Bar Failed to Open');        // Pressure Bar was commanded to extend but failed to reach the sensor
    failedToClose : FB_Fault(name := 'Pressure Bar Failed to Close');      // Pressure Bar was commanded to retract but failed to reach the sensor
	sensorFault : FB_Fault(name := 'Pressure Bar Sensor Fault');		// Both the open and close sensors active at the same time
	obstructionDetected : FB_Fault(name := 'Pressure Bar Obstruction Detected');		// Pressure Bar detected an obstruction
	obstructionFailedToSwitch : FB_Fault(name := 'Pressure Bar Obstruction Detected'); // Pressure bar obstruction sensors should switch when closed
	lightCurtainViolation : FB_Fault(name := 'Light Curtain Violation');
END_STRUCT
END_TYPE
