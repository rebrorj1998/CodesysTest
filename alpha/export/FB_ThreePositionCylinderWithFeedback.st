

FUNCTION_BLOCK FB_ThreePositionCylinderWithFeedback EXTENDS FB_Cylinder IMPLEMENTS ICylinder, IThreePositonCylinder, IFault
VAR_INPUT
    extendedFeedbackInput : BOOL;    //Extended feedback input from I/O
    retractedFeedbackInput : BOOL;    //Retracted feedback input from I/O
    extendFaultDelay : INT := 1000;        //Extend fault delay in MS
    retractFaultDelay : INT := 1000;        //Retract fault delay in MS
    faultMonitoring : BOOL;                    //Fault monitoring enabled if true
END_VAR
VAR_OUTPUT
    failedToExtend : BOOL;            //Failed to Extend Fault
    failedToRetract : BOOL;            //Failed to Retract Fault
END_VAR
VAR
    faultIndication : BOOL;            //Overall fault status of cylinder
    extendFaultTimer : TON;            //Extend Fault Timer
    retractFaultTimer : TON;        //Retract Fault Timer
    resetFaults : BOOL;                //Reset faults
END_VAR



METHOD ResetFault

//Reset all faults
failedToExtend := FALSE;
failedToRetract := FALSE;

PROPERTY Faulted : BOOL


METHOD Exhaust

extendOutput := FALSE;
retractOutput := FALSE;

METHOD Execute

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