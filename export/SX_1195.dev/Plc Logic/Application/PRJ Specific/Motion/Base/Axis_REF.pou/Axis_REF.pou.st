(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'FBVisuCreator'}
FUNCTION_BLOCK Axis_REF IMPLEMENTS IAxisRef
VAR_INPUT
	axisData : sctAxisData;
	jogProfile : sctMotionProfile;
	axisState : eAxisState;			// The axis state
	modeOfOperation : eAZDProfileMode; 	// The set opmode
	powerOn : BOOL; 				// Regulator (power) on/off
	driveEnable : BOOL;				// Deactivate (TRUE) or activate (FALSE) software halt/quickstop
	commStatus : BOOL;				// Whether communication is OK
	ackError : BOOL;				// Acknowledge error (fault reset)
	startHoming : BOOL;				// Tells the axis to start homing, only used in homing mode
	push : BOOL;
	halt : BOOL; 					// Tells the axis to halt using a quick stop, used in all modes
	newSetPoint : BOOL; 			// Tells the axis that a new set point has been given, only used in position mode
	moveAbsTorque : BOOL;           //
	moveAbs : BOOL;					// Perform an absolute move
	moveRel : BOOL;					// Perform a relative move
	moveVel : BOOL;				    // Start a velocity move
	zeroOffset : REAL;              // 
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	targetPosDist : REAL;			// The target position or distance in [u]
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	targetVelocity : REAL;			// The target velocity in [u/s]
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	profileVelocity : REAL;			// The profile velocity in [u/s]
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	profileAcceleration : REAL;		// The profile acceleration in [u/s²]
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	profileDeceleration : REAL;		// The profile deceleration in [u/s²]
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	profileCurrentLimit : REAL;		// The profile current limit in [%]
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	profilePushCurrentLimit : REAL;		// The profile push current limit in [%]
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	quickStopDeceleration : REAL;	// The deceleration for a quick stop in [u/s²]
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	defaultCurrent : REAL;			// Default Current Limit [%]
	finalMove : BOOL;
	error : BOOL; 					// Axis error
END_VAR
VAR_OUTPUT
	{attribute 'FBVisuCreatorFormatString' := '%s'}
	activeOperationMode : eAZDProfileMode; 	// The actual opmode
	operational : BOOL;				// Effective state of the power stage of the axis
	enableState : BOOL;				// Effective state of the software halt/quickstop of the axis (TRUE: deactivated, FALSE: activated), 
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	actPos : REAL;					// Actual position in [u]
	{attribute 'FBVisuCreatorFormatString' := '%1.2f'}
	actVel : REAL;				    // Actual velocity in [u/s]
	setPointAck : BOOL;				// Set if the new set point has been acknowledged, only used in position mode
	targetReached : BOOL;			// Set if the target is reached, only set in position and homing mode
	inVelocity : BOOL; 				// Set if it has reached the commanded velocity, only set in velocity mode
	isHomed : BOOL;			// Set if homing has been performed successfully (implies TargetReached), only set in homing mode
	currentLimitReached : BOOL;
END_VAR

(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
