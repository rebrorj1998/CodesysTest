(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_SlaveAppliedMotionMotorEIP EXTENDS FB_BaseAppliedMotionMotorEIP
VAR_INPUT
	tensionFault : BOOL;
	torque : REAL;
END_VAR
VAR
	commsFailureONS : FB_ONS;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: FB_SlaveAppliedMotionMotorEIP()
//	Description: A PLCOpen Motion compliant library for a Oriental AZ Series drive/motor			 
//	Created by: Evan Ische
//	Created Date: Tuesday, October 13th 2020

// Outputs for Motion Lib
operational := PowerOn;
EnableState := DriveEnable;

// Exit if drive isn't enabled.
IF NOT DriveEnable THEN
	error := FALSE;
	RETURN;
END_IF

SUPER^();

commsFailureONS(CLK := commsFailure);
IF commsFailureONS.OSF THEN
	THIS^.SetTorqueValue(THIS^.torque);
END_IF