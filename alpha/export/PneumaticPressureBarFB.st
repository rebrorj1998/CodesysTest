

FUNCTION_BLOCK PneumaticPressureBarFB
VAR_INPUT
    enable : BOOL;                    // Enable Pneumatic pressure bar
    sealBarEnable : BOOL;            //Enable seal bar
    bagOpenFingersEnable : BOOL;        //Enable bag open fingers
	iPressureBarRetracted : BOOL;
	iPressureBarExtended : BOOL;
END_VAR
VAR_OUTPUT
    state : PRESSURE_BAR_STATES;     //Jaw State
	oPositionBagOpenFingersToRelease : BOOL;
	oExtendSealBar : BOOL;
	oExtendCylinder : BOOL;
	oRetractCylinder : BOOL;
END_VAR
VAR
    _mode : DEVICE_MODES;            // Auto-SemiAuto-Manual
    _ready : BOOL;                    // Ready to be controlled
    _amOpenJaw : BOOL;    // Auto Mode Open Jaw Command
    _amCloseJaw : BOOL;     // Auto Mode Close Jaw Command
	_amSealBag : BOOL;		// Auto mode seal bag command
    enableONS : R_TRIG; //Enable One Shot
    //autoModeSelect : BOOL;            //Auto Mode Selection (Timers)
    startCyclePB : BOOL;                //Start Cycle
    stopCyclePB : BOOL;                //Stop Cycle
    manualExtendHighPressurePB : BOOL;            //Manually Extend Cylinder High Pressure
    manualExtendLowPressurePB : BOOL;            //Manually Extend Cylinder Low Pressure
    manualRetractPB : BOOL;            //Manually Retract Cylinder
    manualExhaustPB : BOOL;            //Manually Echaust Cylinder
    timerExtendedDebounce : TON;            //Timer for extend delay
    timerExtendDwell : TON;            //Timer for extend dwell after extended
    timerRetractedDebounce : TON;        //Timer for retract delay
    timerRetractDwell : TON;        //Timer for retract dwell after extended
    timerSealDwell : TON;            //Timer for seal dwell
    extendDelaySP : INT := 50;    //Extend delay SP
    extendDwellSP : INT := 300;    //Extend dwell SP
    retractDelaySP : INT := 50;        //Retract delay SP
    retractDwellSP : INT := 750;    //Retract dwell SP
    incrementCount : R_TRIG();
    
    bagOpenFingersReleaseDelay : TON := (PT := T#100MS);                //Delay to open Bag Open Fingers after closing pressure bar
    bagOpenFingersGrabDelay : TON := (PT := T#100MS);                //Delay to close Bag Open Fingers after opening pressure bar
    bagOpenFingers : BagOpenFingersFB();
    openingBag : BOOL;                        //Opening bag flag for bag open fingers  
    incrementSealBarCountONS : Standard.R_TRIG;
    incrementBagOpenFinersONS : Standard.R_TRIG;
    autoModeSelected : BOOL;
    semiAutoModeSelected : BOOL;
    manualModeSelected : BOOL;
END_VAR
VAR_IN_OUT
	
END_VAR
//    Function Block: Cylinder
//    Description: This program moves a jaw cylinder back and forth
//    Created by: Ben Hess
//    Created Date: January 16th, 2017

bagOpenFingers(releaseOutput => oPositionBagOpenFingersToRelease);


//Stop the auto cycle if button pressed or coming out of auto mode or moving the servo.
IF stopCyclePB OR NOT (_mode = DEVICE_MODES.SemiAuto) THEN 
    startCyclePB := FALSE;
END_IF

autoModeSelected := (_mode = DEVICE_MODES.Auto);
semiAutoModeSelected := (_mode = DEVICE_MODES.SemiAuto);
manualModeSelected := (_mode = DEVICE_MODES.Manual);

timerExtendedDebounce(PT := INT_TO_TIME(extendDelaySP));
timerExtendDwell(PT := INT_TO_TIME(extendDwellSP));
timerRetractedDebounce(PT := INT_TO_TIME(retractDelaySP));
timerRetractDwell(PT := INT_TO_TIME(retractDwellSP));
bagOpenFingersReleaseDelay();    
bagOpenFingersGrabDelay();

//Go to idle when enabled
enableONS(CLK := enable);
IF enableONS.Q THEN    
    state := PRESSURE_BAR_STATES.Idle;
END_IF

IF NOT enable THEN
    state := PRESSURE_BAR_STATES.Idle;
END_IF

_ready := (_mode = DEVICE_MODES.Auto) AND NOT (state = PRESSURE_BAR_STATES.Fault);


CASE state OF
    
                                    
    PRESSURE_BAR_STATES.Idle :                //Initial state
                                    IF (semiAutoModeSelected AND startCyclePB) OR (autoModeSelected AND _amOpenJaw) THEN
                                        state := PRESSURE_BAR_STATES.OpenJaw;
                                        _amOpenJaw := FALSE;
                                    ELSIF (autoModeSelected AND _amCloseJaw) THEN
                                        state := PRESSURE_BAR_STATES.CloseJaw;
										_amCloseJaw := FALSE;
                                    ELSIF manualModeSelected THEN
                                        state := PRESSURE_BAR_STATES.Manual;
                                    END_IF
                                    oExtendSealBar := FALSE;
                                    
    
    PRESSURE_BAR_STATES.OpenJaw :                //Open jaw by extending cylinder
                                    ExtendCylinderHighPressure();
                                    state := PRESSURE_BAR_STATES.OpeningJaw;
    
    PRESSURE_BAR_STATES.OpeningJaw :            //
                                    //This delay is a debounce for the sensors.
                                    IF iPressureBarExtended THEN
                                        timerExtendedDebounce.IN := TRUE;
                                        IF timerExtendedDebounce.Q THEN
                                            state := PRESSURE_BAR_STATES.JawOpened;
                                            timerExtendedDebounce.IN := FALSE;
                                        END_IF
                                    END_IF
                                    //If we are opening bag this cycle then grab it now
                                    bagOpenFingersGrabDelay.IN := bagOpenFingersEnable;
                                    IF bagOpenFingersGrabDelay.Q THEN
                                        bagOpenFingers.Grab();
                                        bagOpenFingersGrabDelay.IN := FALSE;
                                    END_IF
                                    
                                    
    
    PRESSURE_BAR_STATES.JawOpened :            //Jaw is opened.  If in semi auto mode, go to close jaw after extend dwell. 
                                    IF (semiAutoModeSelected AND startCyclePB) OR (autoModeSelected AND _amCloseJaw) THEN
                                        timerExtendDwell.IN := TRUE;
                                    END_IF
                                    
                                    IF timerExtendDwell.Q  THEN
                                        state := PRESSURE_BAR_STATES.CloseJaw;
                                        _amCloseJaw := FALSE;
                                        timerExtendDwell.IN := FALSE;
                                    END_IF
    
    PRESSURE_BAR_STATES.CloseJaw :            //Close jaw by retracting cylinder
                                    RetractCylinder();
                                    state := PRESSURE_BAR_STATES.ClosingJaw;
    
    PRESSURE_BAR_STATES.ClosingJaw :            //
                                    //This delay is a debounce after the sensor is seen
                                    IF iPressureBarRetracted THEN
                                        timerRetractedDebounce.IN := TRUE;    
                                        IF timerRetractedDebounce.Q THEN
                                            state := PRESSURE_BAR_STATES.JawClosed;
                                            timerRetractedDebounce.IN := FALSE;
                                        END_IF
                                    END_IF
                                    
                                    
                                    
    
    PRESSURE_BAR_STATES.JawClosed :            //Go to sealing if seal bar enabled, otherwise if in auto mode go to open jaw after retract dwell. Else go back to idle
                                    IF sealBarEnable THEN
                                        state := PRESSURE_BAR_STATES.Sealing;
                                    END_IF
                                    
                                    IF (semiAutoModeSelected AND startCyclePB) OR (autoModeSelected AND _amOpenJaw) THEN
                                        bagOpenFingersReleaseDelay.IN := bagOpenFingersEnable;
                                        timerRetractDwell.IN := TRUE;
                                    END_IF    
                                    
                                    IF bagOpenFingersReleaseDelay.Q THEN
                                        bagOpenFingers.Release();
                                        bagOpenFingersReleaseDelay.IN := FALSE;
                                    END_IF    
                                    
                                    IF timerRetractDwell.Q THEN
                                        state := PRESSURE_BAR_STATES.OpenJaw;
                                        _amOpenJaw := FALSE;
                                        timerRetractDwell.IN := FALSE;
                                    END_IF

    PRESSURE_BAR_STATES.Sealing :                //Seal sets output for seal bar after closed for a dwell setpoint  Hack for now
                                    timerRetractDwell.IN := TRUE;
                                    
                                    IF (semiAutoModeSelected OR (autoModeSelected AND _amOpenJaw)) AND timerRetractDwell.Q THEN
                                        state := PRESSURE_BAR_STATES.OpenJaw;
                                        timerRetractDwell.IN := FALSE;
                                        _amOpenJaw := FALSE;
                                    END_IF
                                    
                                    bagOpenFingersReleaseDelay.IN := bagOpenFingersEnable;
                                    IF bagOpenFingersReleaseDelay.Q THEN
                                        bagOpenFingers.Release();
                                        bagOpenFingersReleaseDelay.IN := FALSE;
                                    END_IF    
                                        
                                    oExtendSealBar := TIME_TO_REAL(timerRetractDwell.ET) > (retractDwellSP * 0.1) AND TIME_TO_REAL(timerRetractDwell.ET) < (retractDwellSP * 0.8);
    
    PRESSURE_BAR_STATES.Manual :    IF manualExhaustPB THEN
                                        ExhaustCylinder();
                                        manualExhaustPB := FALSE;
                                    ELSIF manualRetractPB THEN
                                        RetractCylinder();
                                        manualRetractPB := FALSE;
                                    ELSIF manualExtendHighPressurePB THEN
                                        ExtendCylinderHighPressure();
                                        manualExtendHighPressurePB := FALSE;
									ELSIF manualExtendLowPressurePB THEN
                                        ExtendCylinderLowPressure();
                                        manualExtendLowPressurePB := FALSE;
                                    END_IF
                                
    PRESSURE_BAR_STATES.Fault : 
    
END_CASE

//Count cycles
incrementCount(CLK :=timerExtendDwell.Q); 
IF incrementCount.Q THEN
    Globals.headCycleCount := Globals.headCycleCount + 1;
END_IF

incrementSealBarCountONS(CLK := oExtendSealBar);
IF incrementSealBarCountONS.Q THEN
    Globals.sealBarCount := Globals.sealBarCount + 1;
END_IF

incrementBagOpenFinersONS(CLK := oPositionBagOpenFingersToRelease);
IF incrementBagOpenFinersONS.Q THEN
    Globals.bagOpenFingersCount := Globals.bagOpenFingersCount + 1;
END_IF

METHOD AutoDoneMovingPassthrough
VAR_INPUT
END_VAR

state := PRESSURE_BAR_STATES.Idle;

METHOD AutoMovingPassthrough
VAR_INPUT
END_VAR

state := PRESSURE_BAR_STATES.Manual;

METHOD ExhaustCylinder
VAR_INPUT
END_VAR

oExtendCylinder := FALSE;
oRetractCylinder := FALSE;

PROPERTY Mode : DEVICE_MODES


PROPERTY Ready : BOOL


METHOD AutoCloseJaw
VAR_INPUT
END_VAR

_amCloseJaw := TRUE;

METHOD ExtendCylinderHighPressure
VAR_INPUT
END_VAR

oExtendCylinder := TRUE;
oRetractCylinder := FALSE;

METHOD ExtendCylinderLowPressure
VAR_INPUT
END_VAR

oExtendCylinder := TRUE;
oRetractCylinder := TRUE;

METHOD AutoOpenJaw
VAR_INPUT
END_VAR

_amOpenJaw := TRUE;

METHOD RetractCylinder
VAR_INPUT
END_VAR

oExtendCylinder := FALSE;
oRetractCylinder := TRUE;

METHOD AutoSealBag
VAR_INPUT
END_VAR

