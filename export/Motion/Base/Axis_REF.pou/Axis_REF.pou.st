(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'FBVisuCreator'}
FUNCTION_BLOCK Axis_REF IMPLEMENTS IAxisRef
VAR_INPUT
	AxisState : AXIS_STATE;			// The axis state
	SetOpMode : OP_MODE; 			// The set opmode
	PowerOn : BOOL; 				// Regulator (power) on/off
	DriveEnable : BOOL;				// Deactivate (TRUE) or activate (FALSE) software halt/quickstop
	AckError : BOOL;				// Acknowledge error (fault reset)
	StartHoming : BOOL;				// Tells the axis to start homing, only used in homing mode
	Halt : BOOL; 					// Tells the axis to halt using a quick stop, used in all modes
	NewSetPoint : BOOL; 			// Tells the axis that a new set point has been given, only used in position mode
	MoveAbs : BOOL;					// Perform an absolute move
	MoveAbsTorque : BOOL;			// Perform an absolute move with a torque l
	MoveRel : BOOL;					// Perform a relative move
	MoveVelo : BOOL;				// Start a velocity move
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	TargetPosDist : REAL;			// The target position or distance in [u]
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	TargetVelocity : REAL;			// The target velocity in [u/s]
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	ProfileVelocity : REAL;			// The profile velocity in [u/s]
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	ProfileAcceleration : REAL;		// The profile acceleration in [u/s²]
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	ProfileDeceleration : REAL;		// The profile deceleration in [u/s²]
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	ProfileCurrentLimit : REAL;		// The profile current limit in [%]
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	QuickStopDeceleration : REAL;	// The deceleration for a quick stop in [u/s²]
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	DefaultCurrent : REAL;			// Default Current Limit [%]
END_VAR
VAR_OUTPUT
	{attribute 'FBVisuCreatorFormatString' := '%s'}
	ActOpMode : OP_MODE; 			// The actual opmode
	CommStatus : BOOL;				// Whether communication is OK
	PowerState : BOOL;				// Effective state of the power stage of the axis
	EnableState : BOOL;				// Effective state of the software halt/quickstop of the axis (TRUE: deactivated, FALSE: activated), 
	Error : BOOL; 					// Axis error
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	ActPos : REAL;					// Actual position in [u]
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	ActVelocity : REAL;				// Actual velocity in [u/s]
	SetPointAck : BOOL;				// Set if the new set point has been acknowledged, only used in position mode
	TargetReached : BOOL;			// Set if the target is reached, only set in position and homing mode
	InVelocity : BOOL; 				// Set if it has reached the commanded velocity, only set in velocity mode
	HomingDone : BOOL;				// Set if homing has been performed successfully (implies TargetReached), only set in homing mode
END_VAR
VAR
END_VAR
VAR_IN_OUT

END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
