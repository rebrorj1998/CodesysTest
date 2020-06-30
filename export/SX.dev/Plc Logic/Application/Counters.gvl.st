(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
{attribute 'qualified_only'}
VAR_GLOBAL
	jawCycleTestCount : FB_MachineCounter(name := 'Jaw Cycle Test Counter');
	baggerCycles : FB_MachineCounter(name := 'Bagger Cycle Counter');
	pressureBarCycles : FB_MachineCounter(name := 'Pressure Bar Cycle Counter');
	(*Counters*)
    
	//passthroughChanges : FB_MachineCounter(name := 'Passthrough Changes Counter');
	//loadPlateCycles : FB_MachineCounter(name := 'Load Plate Cycle Counter');
	//printerCycles : FB_MachineCounter(name := 'Printer Cycle Counter');
	//motorizedSealFlattenerCycles : FB_MachineCounter(name := 'Motorized Seal Flattener Cycles');
	//bagOpenRetryTotal : FB_MachineCounter(name := 'Bag Open Retry Totals');
END_VAR
