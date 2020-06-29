(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
VAR_GLOBAL
    firstScan : BOOL; //First Scan Bit
    pressureBarServoCommsType : MODBUS_COMM_TYPE;  //Comm path to Pressure Bar Servo - 0 = TCP, 1 = RTU
    STEPS_PER_INCH : INT;  //Steps Per Inch for Pressure Bar Servos
    enableDryCycle : BOOL;          // Enable dry cycle
	SystemLog : FB_InternalLogger;
	jawMovingIn : BOOL;
	passthroughChangedFromJog : BOOL;
	machinePowerOK : BOOL;
END_VAR

VAR_GLOBAL CONSTANT
    STEPS_PER_INCH_SEAL_FLATTENER_HORIZONTAL_AXIS_MOTOR  : INT := 2500;
    STEPS_PER_INCH_SEAL_FLATTENER_VERTICAL_AXIS_MOTOR : INT := 2890;        //Steps per inch for NEMA 17 seal flattener finger motor
    STEPS_PER_INCH_BIG_MOTOR : INT := 21872;        //Steps per inch for NEMA 17 motor
    STEPS_PER_INCH_SMALL_MOTOR : INT := 19600;        //Steps per inch for NEMA 11 motor
    STEPS_PER_INCH_SHOW_MOTOR : INT := 18900;        //Steps per inch for NEMA 11 motor
    STEPS_PER_INCH_PRINTER : INT := 4498;            //Steps per inch for printer step servo
    STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY : INT := 5093; // Steps per inch for 20 degree bag delivery motors
	STEPS_PER_INCH_ADJUSTABLE_PASSTHROUGH : INT := 19530;  // Steps per inch for the Adjustable Passthrough motor
	STEPS_PER_INCH_TFBelt : INT := 6833;  // Steps per inch for the Adjustable Passthrough motor
	STEPS_PER_INCH_TFLS : INT := 10000;  // Steps per inch for the Adjustable Passthrough motor
    VELOCITY_IPS_MULTIPLIER_20_DEGREE_BAG_DELIVERY: REAL := 61;
    PASSTHROUGH_ZERO_OFFSET : REAL := 2;            //Zero offset for passthough (minimum passthough)
    MAX_BAG_WIDTH : REAL := 18;                //Passthrough setting
	AMP_MOTOR_RPI : INT := 10;
	MAX_LOGGED_ITEMS : UINT := 500;	// Max items to be logged
END_VAR

VAR_GLOBAL
    headCycleCount : DINT;                 // Head Cycle Counts
	headCycleCount2 : DINT;                 // Head Cycle Counts
    bagGrabberCycleCount : DINT;         // Bag Grabber Cycle Counts
    solenoidCycleCount1 : DINT;         // Solenoid Cycle Cycle Counts (first solenoid)
    motorizedSealFlattenersCount : DINT;         // MSF Cycle Counts
    bagOpenFingersCount : DINT;        // Bag Open Finger Cycles
    sealFlattenerFingersCount : DINT;  // Seal Flattener Fingers Cycle Count
    electricPressureBarCount : DINT;    // Electric Pressure bar Cycle count
    sealBarCount : DINT;                 // Seal bar Cycle count
    bagDeliveryCycleCount : DINT;        // Bag Delivery Cycle Count
    printerCycleCounts : DINT;            // Printer Cycle Counts
    bagsMadeCount : DINT;                // Bags Made
    passthroughChangeCount : DINT;        // Passthrough Changes
	passthroughChangeDistance : UDINT;	// Passthrough Distance Changes in .1 Inches
	solenoidCycleCount2 : DINT;     	// Solenoid Cycle Cycle Counts (Strech SX)	
	solenoidFailureCount2 : UDINT;		// Solenoid Failure Count (Strech SX)
	pickAndPlaceCycleCount : UDINT;		// Pick and place cycle count
	passthroughChangeCount2 : DINT;        // Passthrough Changes
	passthroughChangeDistance2 : UDINT;	// Passthrough Distance Changes in .1 Inches
	bagFailedToGrabBothFingersCount : UDINT; // Both Fingers failed to grab bag
	bagFailedToGrabRightFingerCount : UDINT; // Right Bag Open Finger Failed to Grab Bag
	bagFailedToGrabLeftFingerCount : UDINT; // Left Bag Open Finger Failed to Grab Bag
	successfulBagOpenCount : UDINT;			// Successful Bag Open Count
	rejectedBagCount : UDINT;				// Rejected bag count 
    dryCycleCount  :UDINT;                   // Dry cycle count
	lastPrinterDelta : TIME := T#100MS;
	factoryTestComplete : BOOL;		// 1000 bags test done
END_VAR