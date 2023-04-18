(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_StepServoFaultHandler EXTENDS FB_BaseObject
VAR_INPUT
END_VAR
VAR
	faultCode : DINT;
END_VAR
VAR_OUTPUT
	positionLimit    : FB_Fault(name := Standard.CONCAT(_prefix, 'Motor exceeded position limit - following error'));  // Motor exceeded position limit - following error
	CCWLimit         : BOOL;                                                                                           // Counter-Clockwise Limit Reached
	CWLimit          : BOOL;		                                                                                   // Clockwise Limit Reached
    overTemp         : FB_Fault(name := Standard.CONCAT(_prefix, 'Motor Over Temperature Limit'));                     // Motor Over Temperature Limit
    internalVoltage  : FB_Fault(name := Standard.CONCAT(_prefix, 'Internal Voltage Fault'));                           // Internal Voltage Fault
    overVoltage      : FB_Fault(name := Standard.CONCAT(_prefix, 'Overvoltage Fault'));                                // Overvoltage Fault
	underVoltage     : BOOL;                                                                                           // Undervoltage Fault
    overCurrent      : FB_Fault(name := Standard.CONCAT(_prefix, 'Motor Overcurrent'));                                // Motor Overcurrent
    openMotorWinding : FB_Fault(name := Standard.CONCAT(_prefix, 'Motor Detected Open Winding'));                      // Motor Detected Open Winding
    badEncoder       : FB_Fault(name := Standard.CONCAT(_prefix, 'Motor Encoder Failure'));                            // Motor Encoder Failure
	noMove           : FB_Fault(name := Standard.CONCAT(_prefix, 'No Move After Command'));
	currentFoldback  : BOOL;
	commFail         : FB_Fault(name := Standard.CONCAT(_prefix, 'Drive TO Controller Communication Failure'));	       // Drive to Controller Communication Failure
	driveFaulted     : FB_Fault(name := Standard.CONCAT(_prefix, 'Drive is Faulted'));                                 // Drive is faulted
END_VAR
VAR_IN_OUT
	motor : FB_BaseAppliedMotionMotorEIP;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Fucntion Block: FB_StepServoFaultHandler
//    Description: This unpacks the step servo alarm bits from the alarm word received over EIP
//    Created by: Evan Ische
//    Created Date: September 5th, 2018

// Alarm Code
positionLimit.faultTrigger    := faultCode.0 := motor.alarmCode.0;
CCWLimit                                     := motor.alarmCode.1;
CWLimit                                      := motor.alarmCode.2;
overTemp.faultTrigger         := faultCode.1 := motor.alarmCode.3;
internalVoltage.faultTrigger  := faultCode.2 := motor.alarmCode.4;
overVoltage.faultTrigger      := faultCode.3 := motor.alarmCode.5;
underVoltage                                 := motor.alarmCode.6;
overCurrent.faultTrigger      := faultCode.4 := motor.alarmCode.7;
openMotorWinding.faultTrigger := faultCode.5 := motor.alarmCode.8;
noMove.faultTrigger           := faultCode.6 := motor.alarmCode.12;
currentFoldback                              := motor.alarmCode.13;
commFail.faultTrigger         := faultCode.7 := motor.commsFailure;
drivefaulted.faultTrigger     := faultCode.8 := motor.statusCode.2;

motor.error := THIS^.FaultActive;

