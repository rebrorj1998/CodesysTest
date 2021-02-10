(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CylinderFeedback
VAR_INPUT
    extendedFeedbackInput : BOOL;    //Extended feedback input from I/O
    retractedFeedbackInput : BOOL;    //Retracted feedback input from I/O
	extendOutput : BOOL;				// Extend output from valve
	retractOutput : BOOL; 				// Retract output from valve
    extendFaultDelay : INT := 1000;        //Extend fault delay in MS
    retractFaultDelay : INT := 1000;        //Retract fault delay in MS
    faultMonitoring : BOOL;                    //Fault monitoring enabled if true
END_VAR
VAR_OUTPUT
    failedToExtend : BOOL;            //Failed to Extend Fault
    failedToRetract : BOOL;            //Failed to Retract Fault
	faultIndication : BOOL;            //Overall fault status of cylinder
END_VAR
VAR
    
    extendFaultTimer : TON;            //Extend Fault Timer
    retractFaultTimer : TON;        //Retract Fault Timer
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//This code monitors the positon of the cylinder and raises a fault if the cylinder doesn't reach its
//desired postion within the specified time.

//Initialize timers
extendFaultTimer(PT := INT_TO_TIME(extendFaultDelay));
retractFaultTimer(PT := INT_TO_TIME(retractFaultDelay));

//Only enable timers if we are to be monitoring faults
IF faultMonitoring THEN
    extendFaultTimer.IN := (extendOutput AND NOT extendedFeedbackInput);
    retractFaultTimer.IN := (retractOutput AND NOT retractedFeedbackInput);
ELSE 
        extendFaultTimer.IN := FALSE;
        retractFaultTimer.IN := FALSE;
END_IF

//Rasie the alarms
failedToExtend := extendFaultTimer.Q;
failedToRetract := retractFaultTimer.Q;

//Set overall fault indication
faultIndication := failedToExtend OR failedToRetract;