(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE LoadPlateFaultsType :
STRUCT
	failedToDischarge : FB_Fault(name := 'Failed to Discharge');        // Load Plate failed to reach Discharge Position
    failedToLoad : FB_Fault(name := 'Failed to Load');  // Load Plate failed to reach Loading Position
	sensorFault : FB_Fault(name := 'Failed to Sensor Fault');		// Both sensors active at the same time
END_STRUCT
END_TYPE
