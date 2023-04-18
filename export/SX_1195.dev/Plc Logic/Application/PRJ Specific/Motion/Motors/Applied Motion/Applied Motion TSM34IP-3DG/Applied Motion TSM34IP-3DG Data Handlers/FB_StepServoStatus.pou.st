(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_StepServoStatus
VAR_INPUT
    statusCode : INT;
END_VAR
VAR_OUTPUT
    motorEnabled : BOOL;        //Motor Enabled (Motor Disabled if this bit = 0)
    sampling : BOOL;      //Sampling (for Quick Tuner)
    driveFaulted : BOOL;      //Drive Fault (check Alarm Code)
    inPosition : BOOL;      //In Position (motor is in position)
    moving : BOOL;      //Moving (motor is moving)
    jogging    : BOOL;      //Jogging (currently in jog mode)
    stopping : BOOL;      //Stopping (in the process of stopping from a stop command)
    waitingForInput : BOOL;      //Waiting (for an input; executing a WI command)
    saving : BOOL;      //Saving (parameter data is being saved)
    alarmPresent : BOOL;      //Alarm present (check Alarm Code)
    homing : BOOL;      //Homing (executing an SH command)
    waitingForTime : BOOL;      //Waiting (for time; executing a WD or WT command)
    wizardRunning : BOOL;      //Wizard running (Timing Wizard is running)
    checkingEncoder    : BOOL;      //Checking encoder (Timing Wizard is running)
    Q_ProgramRunning : BOOL;      //Q Program is running
    initializing : BOOL;      //Initializing (happens at power up) ; Servo Ready (for SV200 drives only)
END_VAR
VAR
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Fucntion Block: StepServoStatus
//    Description: This unpacks the step servo status bits from the status word received over modbus
//    Created by: Ben Hess
//    Created Date: January 26th, 2018

motorEnabled := statusCode.0;
sampling := statusCode.1;
driveFaulted := statusCode.2;
inPosition := statusCode.3;
moving := statusCode.4;
jogging := statusCode.5;
stopping := statusCode.6;
waitingForInput := statusCode.7;
saving := statusCode.8;
alarmPresent := statusCode.9;
homing := statusCode.10;
waitingForTime := statusCode.11;
wizardRunning := statusCode.12;
checkingEncoder := statusCode.13;
Q_ProgramRunning := statusCode.14;
initializing := statusCode.15;
