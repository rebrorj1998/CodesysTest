(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
TYPE StepServoFaultsType :
STRUCT
	positionLimit : FB_Fault(name := 'Motor exceeded position limit - following error');        // Motor exceeded position limit - following error
	CCWLimit : FB_Fault(name := 'Counter-Clockwise Limit Reached'); // Counter-Clockwise Limit Reached
	CWLimit : FB_Fault(name := 'Clockwise Limit Reached');		// Clockwise Limit Reached
    overTemp : FB_Fault(name := 'Motor Over Temperature Limit');      // Motor Over Temperature Limit
    internalVoltage : FB_Fault(name := 'Internal Voltage Fault');      // Internal Voltage Fault
    overVoltage    : FB_Fault(name := 'Overvoltage Fault');      // Overvoltage Fault
	underVoltage : FB_Fault(name := 'Undervoltage Fault'); 	// Undervoltage Fault
    overCurrent : FB_Fault(name := 'Motor Overcurrent');      // Motor Overcurrent
    openMotorWinding : FB_Fault(name := 'Motor Detected Open Winding');      // Motor Detected Open Winding
    badEncoder : FB_Fault(name := 'Motor Encoder Failure');      // Motor Encoder Failure
	noMove : FB_Fault(name := 'No Move After Command');
	currentFoldback : FB_Fault(name := 'Current Foldback');
	commFail : FB_Fault(name := 'Drive to Controller Communication Failure');	// Drive to Controller Communication Failure
	notHomed : FB_Fault(name := 'Drive is not homed'); // Drive is not homed
END_STRUCT
END_TYPE
