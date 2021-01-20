(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_CylinderWithFeedback EXTENDS FB_Cylinder IMPLEMENTS ICylinder, IFault
VAR_INPUT
    extendedFeedbackInput : BOOL;    //Extended feedback input from I/O
    retractedFeedbackInput : BOOL;    //Retracted feedback input from I/O
    extendFaultDelay : INT := 1000;        //Extend fault delay in MS
    retractFaultDelay : INT := 1000;        //Retract fault delay in MS
    faultMonitoring : BOOL;                    //Fault monitoring enabled if true
END_VAR
VAR_OUTPUT
    failedToExtend : FB_Fault;            //Failed to Extend Fault
    failedToRetract : FB_Fault;            //Failed to Retract Fault
END_VAR
VAR
    faultIndication : BOOL;            //Overall fault status of cylinder
    extendFaultTimer : TON;            //Extend Fault Timer
    retractFaultTimer : TON;        //Retract Fault Timer
    resetFaults : BOOL;                //Reset faults
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
