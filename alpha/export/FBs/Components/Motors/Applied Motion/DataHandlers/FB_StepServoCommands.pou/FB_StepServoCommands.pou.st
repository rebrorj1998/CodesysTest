(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{analysis -166, -35, -36, -38, -148}
FUNCTION_BLOCK FB_StepServoCommands
VAR_INPUT
       
END_VAR
VAR_OUTPUT
    commandWord : DINT;
	commandSent : BOOL;
END_VAR
VAR
	_idleState : BOOL; // Idle State (Send this between repeated commands)
    _enable : BOOL; // Enable
    _disable : BOOL; // Disable
    _feedToLength : BOOL; // Start Move - FL
    _feedToPosition : BOOL; // Start Move - FP
    _feedToSensor : BOOL; // Start Move - FS (sensor)
    _feedToDoubleSensor : BOOL; // Start Move - FD (double sensor)
    _feedToSensorSafety : BOOL; // Start Move - FY (sensor w/ safety distance)
    _feedToSensorMask : BOOL; // Start Move - FM (sensor w/ mask distance)
    _feedAndSetOutput : BOOL; // Start Move - FO (set output)
    _feedSpeedChange : BOOL; // Start Move - FC
    _seekHome : BOOL; // Start Move - SH
    _findHome : BOOL; // Start Move - FH
    _followEncoder : BOOL; // Start Move - FE
    _stopAndKillCrash : BOOL; // Stop/Kill - AM
    _stopAndKillNormal : BOOL; // Stop/Kill - DE
    _startJog : BOOL; // Start Jogging
    _updateJogSpeed : BOOL; // Update Jog Speed
    _sendHostCommand : BOOL; // Send Host Command
    _sendQAndExecute : BOOL; // Q Load & Execute (QX)
    _alarmReset : BOOL; // Alarm Reset - AR 
	clearCommandWordTimer : TON := (PT := REAL_TO_TIME(INT_TO_REAL(Globals.AMP_MOTOR_RPI) * 1.5));
	clearCommandWordTimer2 : TON := (PT := REAL_TO_TIME(INT_TO_REAL(Globals.AMP_MOTOR_RPI) * 1.5));
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{analysis -166, -35, -36, -148}
//    Fucntion Block: FB_StepServoCommands
//    Description: This packs the step servo command bits into the register send over EIP
//    Created by: Ben Hess
//    Created Date: May 11th, 2018

// Set the proper output bit
commandWord.0 := _idleState;
commandWord.1 := _enable;
commandWord.2 := _disable;
commandWord.3 := _feedToLength;
commandWord.4 := _feedToPosition;
commandWord.5 := _feedToSensor;
commandWord.6 := _feedToDoubleSensor;
commandWord.7 := _feedToSensorSafety;
commandWord.8 := _feedToSensorMask;
commandWord.9 := _feedAndSetOutput;
commandWord.10 := _feedSpeedChange;
commandWord.11 := _seekHome;
commandWord.12 := _findHome;
commandWord.13 := _followEncoder;
commandWord.14 := _stopAndKillCrash;
commandWord.15 := _stopAndKillNormal;
commandWord.16 := _startJog;
commandWord.17 := _updateJogSpeed;
commandWord.18 := _sendHostCommand;
commandWord.19 := _sendQAndExecute;
commandWord.20 := _alarmReset;

IF commandWord <> 0 THEN
	commandWord := commandWord;
END_IF

// CLear the command bits after 1.3x motor RPI
clearCommandWordTimer(IN := commandWord <> 0);
clearCommandWordTimer2();
IF clearCommandWordTimer.Q THEN
	THIS^.Clear();
	clearCommandWordTimer2.IN := TRUE;
END_IF

IF clearCommandWordTimer2.Q THEN
	commandSent := TRUE;
	clearCommandWordTimer2.IN := FALSE;
END_IF

