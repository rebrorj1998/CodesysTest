(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK ElectricPressureBarFB IMPLEMENTS IComponentStatus
VAR_INPUT
    enable : BOOL;
END_VAR
VAR_IN_OUT

END_VAR
VAR_OUTPUT
END_VAR
VAR
    electricPressureBarMotor : FB_FestoMotor();
    delay: TON := (PT := T#1S);
    state : PRESSURE_BAR_STATES;
    enableElectricPressureBarONS : R_TRIG();
    
    _mode : DEVICE_MODES;    // Auto-SemiAuto-Manual
    _ready : BOOL;            // Ready to be controlled
    _amOpenJaw : BOOL;    // Auto Mode Open Jaw Command
    _amCloseJaw : BOOL;     // Auto Mode Close Jaw Command
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: ElectricPressureBarFB
//    Description: This function block is the state machine for the electric pressure bar
//    
//    Created by: Ben Hess
//    Created Date: Monday, April 16, 2018

electricPressureBarMotor(deviceType := FML.CMMP_AS,
                                        isFPCActive := TRUE, 
                                        ptrReadFHPPRegister := ADR(%IW145), 
                                        ptrReadFPCRegister := ADR(%IW149),
                                        ptrWriteFHPPRegister := ADR(%QW82),
                                        ptrWriteFPCRegister := ADR(%QW86));                                    
electricPressureBarMotor.Execute();

delay();

//Report as ready if mode is auto and we're not faulted
_ready := (_mode = DEVICE_MODES.Auto) AND NOT (state = PRESSURE_BAR_STATES.Fault);


enableElectricPressureBarONS(CLK := enable);
IF enableElectricPressureBarONS.Q THEN
    state := PRESSURE_BAR_STATES.Idle;
END_IF

IF NOT enable THEN
        state := PRESSURE_BAR_STATES.Fault;
END_IF

CASE state OF
    PRESSURE_BAR_STATES.Idle:        IF enable AND _mode = DEVICE_MODES.SemiAuto OR (_mode = DEVICE_MODES.Auto AND _amCloseJaw) THEN
                                        state := PRESSURE_BAR_STATES.CloseJaw;
                                        _amCloseJaw := FALSE;
                                    END_IF
    
    PRESSURE_BAR_STATES.OpenJaw:    electricPressureBarMotor.ExecuteStoredProgram(1);
                                    IF electricPressureBarMotor.CommandAcknowledged THEN
                                        state := PRESSURE_BAR_STATES.OpeningJaw;
                                        Globals.electricPressureBarCount := Globals.electricPressureBarCount + 1;
                                    END_IF
        
    
    PRESSURE_BAR_STATES.OpeningJaw:    
                                    IF electricPressureBarMotor.ActiveStoredProgramNumber = 1 AND electricPressureBarMotor.InPosition THEN
                                        state := PRESSURE_BAR_STATES.JawOpened;
                                    END_IF
                                    
    PRESSURE_BAR_STATES.JawOpened:     IF _mode = DEVICE_MODES.SemiAuto THEN
                                        delay.IN := TRUE;
                                        IF delay.Q THEN
                                            state := PRESSURE_BAR_STATES.CloseJaw;
                                            delay.IN := FALSE;
                                        END_IF
                                    ELSIF _mode = DEVICE_MODES.Auto AND _amCloseJaw THEN
                                        state := PRESSURE_BAR_STATES.CloseJaw;
                                        _amCloseJaw := FALSE;
                                    END_IF
        
    PRESSURE_BAR_STATES.CloseJaw:    electricPressureBarMotor.ExecuteStoredProgram(2);
                                    IF electricPressureBarMotor.CommandAcknowledged THEN
                                        state := PRESSURE_BAR_STATES.ClosingJaw;
                                        Globals.electricPressureBarCount := Globals.electricPressureBarCount + 1;
                                    END_IF
                                    
    
    PRESSURE_BAR_STATES.ClosingJaw:    IF electricPressureBarMotor.ActiveStoredProgramNumber = 2 AND electricPressureBarMotor.InPosition THEN
                                        state := PRESSURE_BAR_STATES.JawClosed;
                                    END_IF
                                    
    PRESSURE_BAR_STATES.JawClosed:    IF _mode = DEVICE_MODES.SemiAuto THEN
                                        delay.IN := TRUE;
                                        IF delay.Q THEN
                                            state := PRESSURE_BAR_STATES.OpenJaw;
                                            delay.IN := FALSE;
                                        END_IF
                                    ELSIF _mode = DEVICE_MODES.Auto AND _amOpenJaw THEN
                                        state := PRESSURE_BAR_STATES.OpenJaw;
                                        _amOpenJaw := FALSE;
                                    END_IF
    
    PRESSURE_BAR_STATES.Fault:        ClearCommands();        
    
    
END_CASE