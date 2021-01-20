(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Execute
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
failedToExtend S= extendFaultTimer.Q;
failedToRetract S= retractFaultTimer.Q;

//Set overall fault indication
faultIndication := failedToExtend OR failedToRetract;