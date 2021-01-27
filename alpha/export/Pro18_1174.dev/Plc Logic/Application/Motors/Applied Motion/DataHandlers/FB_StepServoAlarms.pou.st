(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_StepServoAlarms
VAR_INPUT
    alarmCode : INT;
END_VAR
VAR_OUTPUT
    positionLimit : BOOL;        // FAULT - Motor exceeded position limit - following error
    CCWLimit : BOOL;      // WARNING - Motor is at CCW Limit
    CWLimit : BOOL;      // WARNING - Motor is at CW Limit
    overTemp : BOOL;      // FAULT - Motor Over Temperature Limit
    internalVoltage : BOOL;      // FAULT - Internal Voltage Fault
    overVoltage    : BOOL;      // FAULT - Overvoltage Fault
    underVoltage : BOOL;      // WARNING - Undervoltage Warning
    overCurrent : BOOL;      // FAULT - Motor Overcurrent
    openMotorWinding : BOOL;      // FAULT - Motor Detected Open Winding
    badEncoder : BOOL;      // FAULT - Motor Encoder Failure
    commError : BOOL;      // WARNING - Communications Error
    badFlash : BOOL;      // WARNING - Bad Flash
    noMove : BOOL;      // WARNING - No Move
    currentFoldback    : BOOL;      // WARNING - Current Foldback
    blankQSegment : BOOL;      // WARNING - Blank Q Segment
    NVMemoryDoubleError : BOOL;      // WARNING - NV Memory Double Error
END_VAR
VAR
END_VAR
VAR_IN_OUT
	faults : StepServoFaultsType;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Fucntion Block: FB_StepServoAlarms
//    Description: This unpacks the step servo alarm bits from the alarm word received over EIP
//    Created by: Ben Hess
//    Created Date: September 5th, 2018

faults.positionLimit.faultTrigger := positionLimit := alarmCode.0;
faults.CCWLimit.faultTrigger := CCWLimit := alarmCode.1;
faults.CWLimit.faultTrigger := CWLimit := alarmCode.2;
faults.overTemp.faultTrigger := overTemp := alarmCode.3;
faults.internalVoltage.faultTrigger := internalVoltage := alarmCode.4;
faults.overVoltage.faultTrigger := overVoltage := alarmCode.5;
faults.underVoltage.faultTrigger := underVoltage := alarmCode.6;
faults.overCurrent.faultTrigger := overCurrent    := alarmCode.7;
faults.openMotorWinding.faultTrigger := openMotorWinding := alarmCode.8;
faults.badEncoder.faultTrigger := badEncoder := alarmCode.9;
commError := alarmCode.10;
badFlash := alarmCode.11;
faults.noMove.faultTrigger := noMove := alarmCode.12;
faults.currentFoldback.faultTrigger := currentFoldback := alarmCode.13;
blankQSegment := alarmCode.14;
NVMemoryDoubleError := alarmCode.15;
