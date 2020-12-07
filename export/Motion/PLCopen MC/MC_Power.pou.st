(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK MC_Power
VAR_INPUT
	Enable : BOOL; 			// Enables the FUNCTION block 
	RegulatorOn : BOOL; 	// Enables the power stage 
	DriveStart : BOOL; 		// Disables the quickstop mechanism 
END_VAR
VAR_OUTPUT
	Status : BOOL; 					// Axis ready for motion 
	RegulatorRealState : BOOL; 		// Effective state OF the power stage 
	DriveStartRealState : BOOL; 	// Effective state of the quickstop mechanism 
	Busy : BOOL; 					// Function block is executing 
	Error : BOOL; 					// Signals that an error has occured 
	ErrorID : MC_ERROR; 			// Error number 
END_VAR
VAR
	EnableOSR : Standard.R_TRIG;
	MC_State : INT;
END_VAR
VAR_IN_OUT
	Axis : Axis_REF;		// Reference to the axis 
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Function Block: MC_Power
//	Description: 	Controls the power stage of an axis and can be used to issue a quick stop.
//					◾A call of MC_Power_SML with bRegulatorOn=FALSE sets the axis state to PowerOff (disabled).
//					◾A call of MC_Power_SML with bRegulatorOn``=``TRUE on a disabled axis sets the axis state to Standstill, if there is no error on the axis. If an error is detected, the state of the axis is set to ErrorStop.
//					◾If the inputs Enable, bRegulatorOn and bDriveStart are ``TRUE but the output Status remains in FALSE for a long time, there may be a problem with the power stage, or an external halt may be set.
//					◾If power fails (also during operation), the axis state is set to ErrorStop.
//	Created by: Ben Hess
//	Created Date: May 6th, 2019

Status := Axis.PowerState AND Axis.EnableState;

RegulatorRealState := Axis.PowerState;
DriveStartRealState := Axis.EnableState;

IF NOT Enable THEN
	Axis.PowerOn := Axis.DriveEnable := FALSE;
ELSE
	Axis.PowerOn := RegulatorOn;
	Axis.DriveEnable := DriveStart;
END_IF