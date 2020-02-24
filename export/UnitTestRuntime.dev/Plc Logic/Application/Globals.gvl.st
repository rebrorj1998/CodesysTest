(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
{attribute 'global_init_slot' := '49994'}
VAR_GLOBAL
	firstScan : BOOL; //First Scan Bit
	SystemLog : FB_InternalLogger;
    //baggerCycles : FB_MachineCounter(name := 'Bagger Cycle Counter');
	//pressureBarCycles : FB_MachineCounter(name := 'Pressure Bar Cycle Counter');
	//passthroughChanges : FB_MachineCounter(name := 'Passthrough Changes Counter');
	//loadPlateCycles : FB_MachineCounter(name := 'Load Plate Cycle Counter');
	//printerCycles : FB_MachineCounter(name := 'Printer Cycle Counter');
END_VAR

VAR_GLOBAL CONSTANT
	MAX_LOGGED_ITEMS : UINT := 500;	// Max items to be logged
	AMP_MOTOR_RPI : INT := 10;		//AMP Motor Comms RPI in mS
	STEPS_PER_INCH_SEAL_FLATTENER_HORIZONTAL_AXIS_MOTOR  : INT := 2500; // Steps per in for the horizontal seal flatteners
	STEPS_PER_INCH_BAG_DELIVERY : INT := 5093;  // Steps per inch for bag delivery motors
	STEPS_PER_INCH_ADJUSTABLE_PASSTHROUGH : INT := 19600;  // Steps per inch for the Adjustable Passthrough motor
	IO_MASTER_INPUT_BYTES : INT := 64;
	IO_MASTER_OUTPUT_BYTES : INT := 22;
	MAX_VALVE_MANIFOLD_STATIONS : UINT := 12;
END_VAR