(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE CylinderFaultsType :
STRUCT
	failedToExtend : FaultType;        // Cylinder was commanded to extend but failed to reach the sensor
    failedToRetract : FaultType;      // Cylinder was commanded to retract but failed to reach the sensor
	sensorFault : FaultType;		// Both Extend and Retract sensors active at the same time
END_STRUCT
END_TYPE
