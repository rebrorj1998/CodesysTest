(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK PneumaticPressureBarFB_1 EXTENDS BaseComponentFB
VAR_INPUT
	iPressureBarRetracted : BOOL;
	iPressureBarExtended : BOOL;
	iPressureBarNotObstructed : BOOL;
	iLightCurtainsClear : BOOL;
	lightCurtainsInstalled : BOOL;
END_VAR
VAR_OUTPUT
    state : PRESSURE_BAR_STATES;     //Jaw State
	oExtendCylinder : BOOL;
	oRetractCylinder : BOOL;
	faults : PressureBarFaultsType;
END_VAR
VAR
    _amOpenJaw : BOOL;    // Auto Mode Open Jaw Command
    _amCloseJaw : BOOL;     // Auto Mode Close Jaw Command
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
	timerObsSwitchFault : Standard.TON;
    extendDelaySP : INT := 50;    //Extend delay SP
    extendDwellSP : INT := 300;    //Extend dwell SP
    retractDelaySP : INT := 50;        //Retract delay SP
    retractDwellSP : INT := 750;    //Retract dwell SP
    incrementCount : R_TRIG();
    incrementSealBarCountONS : Standard.R_TRIG;
    incrementBagOpenFinersONS : Standard.R_TRIG;
	faultTimer : Standard.TON;
	fillTimer : Standard.TON := (PT := T#150MS);
END_VAR
VAR_IN_OUT
	cumulativeHeadCycleCount : DINT;
END_VAR(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: Cylinder
//    Description: This program moves a jaw cylinder back and forth
//    Created by: Ben Hess
//    Created Date: January 16th, 2017

SUPER^();

//Stop the auto cycle if button pressed or coming out of auto mode or moving the servo.
IF stopCyclePB OR NOT (_mode = DEVICE_MODES.SemiAuto) THEN 
    startCyclePB := FALSE;
END_IF

HMIData.pressureBarService.retractedFeedback := iPressureBarRetracted;
HMIData.pressureBarService.extendedFeedback := iPressureBarExtended;

autoModeSelected := (_mode = DEVICE_MODES.Auto);
semiAutoModeSelected := (_mode = DEVICE_MODES.SemiAuto);
manualModeSelected := (_mode = DEVICE_MODES.Manual);

timerExtendedDebounce(PT := INT_TO_TIME(extendDelaySP));
timerExtendDwell(PT := INT_TO_TIME(extendDwellSP));
timerRetractedDebounce(PT := INT_TO_TIME(retractDelaySP));
timerRetractDwell(PT := INT_TO_TIME(retractDwellSP));
timerObsSwitchFault(PT := T#100MS);
//Go to idle when enabled
IF enableONS.Q OR resetONS.Q THEN    
    state := PRESSURE_BAR_STATES.Idle;
	_reset := FALSE;
	timerObsSwitchFault.IN := FALSE;
END_IF

IF NOT enable THEN
    state := PRESSURE_BAR_STATES.Idle;
END_IF

_ready := (_mode = DEVICE_MODES.Auto) AND NOT (state = PRESSURE_BAR_STATES.Fault);

faultTimer();
fillTimer(IN := (state = PRESSURE_BAR_STATES.FillCylindersWithAirThenClose OR state = PRESSURE_BAR_STATES.FillCylindersWithAirThenOpen));

CASE state OF
    
                                    
    PRESSURE_BAR_STATES.Idle :                //Initial state
                                    IF (semiAutoModeSelected AND startCyclePB) OR (autoModeSelected AND _amOpenJaw) OR HMIData.pressureBarService.extendCommand THEN
										//IF lightCurtainsInstalled THEN
											state := PRESSURE_BAR_STATES.FillCylindersWithAirThenOpen;
										//ELSE
											//state := PRESSURE_BAR_STATES.OpenJaw;
										//END_IF
                                        
                                        _amOpenJaw := FALSE;
										HMIData.pressureBarService.extendCommand := FALSE;
                                    ELSIF (autoModeSelected AND _amCloseJaw) OR HMIData.pressureBarService.retractCommand THEN
                                        //IF lightCurtainsInstalled THEN
											state := PRESSURE_BAR_STATES.FillCylindersWithAirThenClose;
										//ELSE
											//state := PRESSURE_BAR_STATES.CloseJaw;
										//END_IF
										_amCloseJaw := FALSE;
										HMIData.pressureBarService.retractCommand := FALSE;
                                    ELSIF manualModeSelected THEN
                                        state := PRESSURE_BAR_STATES.Manual;
                                    END_IF
                                    timerObsSwitchFault.IN := FALSE;
									
    PRESSURE_BAR_STATES.FillCylindersWithAirThenOpen :		// Fill the cylinders on both sides with air to prevent slamming
	 								
									ExtendCylinderLowPressure();
									IF fillTimer.Q THEN
										state := PRESSURE_BAR_STATES.OpenJaw;
									END_IF
									
    PRESSURE_BAR_STATES.OpenJaw :                //Open jaw by extending cylinder
                                    ExtendCylinderHighPressure();
                                    state := PRESSURE_BAR_STATES.OpeningJaw;
    
    PRESSURE_BAR_STATES.OpeningJaw :            //
                                    //This delay is a debounce for the sensors.
                                    faultTimer.PT := T#3S;
									faultTimer.IN := TRUE;
									IF iPressureBarExtended THEN
                                        timerExtendedDebounce.IN := TRUE;
                                        IF timerExtendedDebounce.Q THEN
											IF lightCurtainsInstalled THEN
												ExhaustCylinder();
											END_IF
                                            state := PRESSURE_BAR_STATES.JawOpened;
                                            timerExtendedDebounce.IN := FALSE;
											faultTimer.IN := FALSE;
                                        END_IF
									ELSIF faultTimer.Q THEN
										faultTimer.IN := FALSE;
										ExhaustCylinder();
										faults.failedToOpen.Trigger();
										state := PRESSURE_BAR_STATES.Fault;
                                    END_IF
									
									IF (NOT iLightCurtainsClear AND lightCurtainsInstalled) THEN
										faultTimer.IN := FALSE;
										faults.lightCurtainViolation.Trigger();
										ExhaustCylinder();
										state := PRESSURE_BAR_STATES.Fault;
									END_IF

                                    
                                    
    
    PRESSURE_BAR_STATES.JawOpened :            //Jaw is opened.  If in semi auto mode, go to close jaw after extend dwell. 
                                    IF (semiAutoModeSelected AND startCyclePB) THEN
                                        timerExtendDwell.IN := TRUE;
                                    END_IF
                                    
                                    IF timerExtendDwell.Q OR (autoModeSelected AND _amCloseJaw) OR HMIData.pressureBarService.retractCommand THEN
                                        //IF lightCurtainsInstalled THEN
											state := PRESSURE_BAR_STATES.FillCylindersWithAirThenClose;
										//ELSE
										//	state := PRESSURE_BAR_STATES.CloseJaw;
										//END_IF
                                        _amCloseJaw := FALSE;
										HMIData.pressureBarService.retractCommand := FALSE;
                                        timerExtendDwell.IN := FALSE;
                                    END_IF
    
	PRESSURE_BAR_STATES.FillCylindersWithAirThenClose :		// Fill the cylinders on both sides with air to prevent slamming
	 								
									ExtendCylinderLowPressure();
									IF fillTimer.Q THEN
										state := PRESSURE_BAR_STATES.CloseJaw;
									END_IF
									
									
    PRESSURE_BAR_STATES.CloseJaw :            //Close jaw by retracting cylinder
                                    RetractCylinder();
                                    state := PRESSURE_BAR_STATES.ClosingJaw;
    
    PRESSURE_BAR_STATES.ClosingJaw :            //
                                    //This delay is a debounce after the sensor is seen
                                    faultTimer.PT := T#3S;
									faultTimer.IN := TRUE;
									IF iPressureBarRetracted THEN
                                        timerRetractedDebounce.IN := TRUE;    
                                        IF timerRetractedDebounce.Q THEN
                                            state := PRESSURE_BAR_STATES.JawClosed;
                                            timerRetractedDebounce.IN := FALSE;
											faultTimer.IN := FALSE;
                                        END_IF
									ELSIF faultTimer.Q THEN
										faultTimer.IN := FALSE;
										faults.failedToClose.Trigger();
										ExtendCylinderLowPressure();
										state := PRESSURE_BAR_STATES.Fault;
                                    END_IF
									
									IF (NOT iLightCurtainsClear AND lightCurtainsInstalled) THEN
										faultTimer.IN := FALSE;
										faults.lightCurtainViolation.Trigger();
										ExhaustCylinder();
										state := PRESSURE_BAR_STATES.Fault;
									END_IF
									
									IF NOT iPressureBarNotObstructed AND NOT iPressureBarRetracted THEN
										faults.obstructionDetected.Trigger();
										ExtendCylinderLowPressure();
										faultTimer.IN := FALSE;
										state := PRESSURE_BAR_STATES.Fault;
									END_IF
                                    
                                    
                                    
    
    PRESSURE_BAR_STATES.JawClosed :            //Go to sealing if seal bar enabled, otherwise if in auto mode go to open jaw after retract dwell. Else go back to idle

                                    
                                    IF (semiAutoModeSelected AND startCyclePB) THEN
                                        timerRetractDwell.IN := TRUE;
                                    END_IF    
									IF iPressureBarNotObstructed THEN
										timerObsSwitchFault.IN := TRUE;
										IF timerObsSwitchFault.Q THEN
											ExtendCylinderLowPressure();
											faults.obstructionFailedToSwitch.Trigger();
											state := PRESSURE_BAR_STATES.Fault;
										END_IF
									ELSE
										timerObsSwitchFault.IN := FALSE;
									END_IF
                                    
                                    IF timerRetractDwell.Q OR (autoModeSelected AND _amOpenJaw) OR HMIData.pressureBarService.extendCommand THEN
                                        state := PRESSURE_BAR_STATES.OpenJaw;
										HMIData.pressureBarService.extendCommand := FALSE;
                                        _amOpenJaw := FALSE;
                                        timerRetractDwell.IN := FALSE;
                                    END_IF

 
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
									ExhaustCylinder();
    
END_CASE

IF NOT iPressureBarNotObstructed AND Globals.jawMovingIn THEN
										faults.obstructionDetected.Trigger();
										//ExtendCylinderLowPressure();
										ExhaustCylinder();
										faultTimer.IN := FALSE;
										state := PRESSURE_BAR_STATES.Fault;
END_IF
IF iPressureBarExtended AND iPressureBarRetracted THEN
	faults.sensorFault.Trigger();
	state := PRESSURE_BAR_STATES.Fault;
END_IF

//Count cycles
incrementCount(CLK :=timerExtendDwell.Q); 
IF incrementCount.Q THEN
    cumulativeHeadCycleCount := cumulativeHeadCycleCount + 1;
END_IF
