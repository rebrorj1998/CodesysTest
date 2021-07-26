(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_BagDelivery EXTENDS FB_BaseComponent IMPLEMENTS IComponentStatus
VAR_INPUT
    feedBagPB : BOOL;                // Manually Feed bag out
	jogForwardPB : BOOL;
	jogReversePB : BOOL;
	reverseToPrintheadRequired : BOOL;
    bagsToFeedSetpoint : INT;        // Bags to feed setpoint for testing
    reverseDistanceSetpoint : REAL := -3;  // Distance to reverse
    bagLengthSetpoint : REAL := 23.5;  // Bag length to feed
    accelSetpoint : INT := 600;            // Acceleration Setpoint
    decelSetpoint : INT := 2000;        // Deceleration Setpoint
    reverseVelocitySetpoint : INT := 3;            // Reverse Velocity setoint (IPS)
    feedVelocitySetpoint : INT := 55;            // Bag Feed Velocity setoint (IPS)
    printVelocitySetpoint : UDINT := 6;            // Print speed (IPS)
    sealOffsetSetpoint : REAL := 1.5;            // Seal Offset
    printOffsetSetpoint : REAL := 3;            // Print Offset
    printLengthSetpoint : REAL := 8;                    // Print length
	reverseToPrintHeadSetpoint : REAL := -1.25;
	feedToPhotoeyeSetpoint : REAL := 2.0;
	useLastPrinterDelta : BOOL := TRUE;
	tensionFailONS : FB_ONS;
	bagFeedMasterMotorCommFailInput : BOOL;
	bagFeedRearMotorCommFailInput : BOOL;
	stepsPerInchSetting : INT;
	velocityMultiplier : REAL;
END_VAR
VAR_OUTPUT
    state : BAG_DELIVERY_STATES;    // Current state of bag delivery component
	reverseFault : FB_Fault(name := 'Reverse Fault');
	noBagOverEye : FB_Fault(name := 'No bag over Photoeye');
	bagTensionFault : FB_Fault(name := 'Bag Tension Fault');
	remainingLength : REAL;            // Remaining bag length after print
END_VAR
VAR
    delay : TON := (PT := T#100MS);    // Delay for testing
	jogForwardONS: FB_ONS;
	jogReverseONS: FB_ONS;
	delayForReverseFault : Standard.TON;
	autoFeedDelay : TON := (PT := T#200MS);
	sealBarToPrintHeadLength : REAL;
    bagsCurrentlyFed  :INT;            // Bags currently fed for testing
	delayForPrintFeed : TIME := T#20MS;
	printerExtraFeedLength : REAL := 0.25;
    //bagFeedMasterMotor : FB_AppliedMotionStepServoTCP();
    //bagFeedMasterMotor : FB_AppliedMotionBagDeliveryMotor();
	bagFeedMasterMotor : FB_AppliedMotionBagDeliveryMotor_1();
	bagFeedRearMotor : FB_AppliedMotionBagDeliveryMotor_1();
	accelPercent : REAL := 0.1;
	decelPercent : REAL := 0.05;
    _amReverseBag : BOOL;            // Auto Mode - Reverse bag
    _amFeedBagOut : BOOL;            // Auto Mode - Feed new bag out
    _amWaitForPrinter : BOOL;        // Auto Mode - wait for printer
    _amPrinterReady : BOOL;            // Auto Mode - Printer is ready
    _amStartPrint : BOOL;            // Auto Mode - Start Printing
    _amPrinterDone : BOOL;             // Auto Mode - Printer is Done
	_amFeedToEye : BOOL;			  // Auto Mode - Feed Bag to Eye
	testTorque : BOOL;
	testTorqueValue : DINT := 60;
	reverseSpeedDistanceOffset : REAL;
	checkMotorStatusDelay : TIME := T#25ms;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: BagDeliveryFB
//    Description: This is the state machine for the bag delivery test rig
//    
//    Created by: Ben Hess
//    Created Date: Thursday, April 19, 2018

SUPER^();
tensionFailONS(CLK := iBagTensionFault);
reverseSpeedDistanceOffset := OSCAT_BASIC.SCALE_R(HMIData.bagReverseSpeed,3,10,0,0.5);
reverseToPrintHeadSetpoint := -1.75 + reverseSpeedDistanceOffset;
delay();
delayForReverseFault();
autoFeedDelay(IN := _amFeedBagOut);

bagLengthSetpoint := HMIData.bagLength;
printVelocitySetpoint := HMIData.printSpeed;
sealOffsetSetpoint := HMIData.bagSkirtLength;
printOffsetSetpoint := HMIData.printOffset;
sealBarToPrintHeadLength := ABS(reverseToPrintHeadSetpoint) + 2.25;
printLengthSetpoint := HMIData.printLength;
reverseVelocitySetpoint := TO_INT(HMIData.bagReverseSpeed);
feedVelocitySetpoint := TO_INT(HMIData.bagForwardSpeed);
IF (HMIData.baggerModelSelection = ModelSelection.Pro18) OR (HMIData.baggerModelSelection = ModelSelection.Pro18_02) THEN
	reverseToPrintHeadSetpoint := -1.25;
ELSE
	reverseToPrintHeadSetpoint := -1.0;
END_IF


(*bagFeedMasterMotor(modbusInputParameters := BagDeliverMasterMotorModbusInputs, 
                    stepsPerInchSetpoint := Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY, 
                    reversePolarity := FALSE, 
                    slave := Bag_Delivery_Master_Motor);*)
bagFeedMasterMotor(ptrEIPInputs := ADR(bagDeliveryMotorInputs),
                ptrEIPOutputs := ADR(bagDeliveryMotorOutputs),
                stepsPerInchSetpoint := stepsPerInchSetting,
                //faultHandler := PRG_Bagger.faultHandler,
				reversePolarity := FALSE, 
				defaultCurrentSetpoint := 1150, 
				commFail := bagFeedMasterMotorCommFailInput);
bagFeedMasterMotor.Execute();

bagFeedRearMotor(ptrEIPInputs := ADR(bagRearMotorInputs),
                ptrEIPOutputs := ADR(bagRearMotorOutputs),
                stepsPerInchSetpoint := stepsPerInchSetting,
                //faultHandler := PRG_Bagger.faultHandler,
				reversePolarity := FALSE, 
				defaultCurrentSetpoint := 1150, 
				commFail := bagFeedRearMotorCommFailInput);
bagFeedRearMotor.Execute();

IF testTorque THEN
	//bagFeedRearMotor.SetRearMotorTorqueValue(testTorqueValue);
	testTorque := FALSE;
END_IF

IF enableONS.Q OR resetONS.Q THEN
    IF _mode = DEVICE_MODES.Manual THEN 
        state := BAG_DELIVERY_STATES.Manual;
    ELSE
        state := BAG_DELIVERY_STATES.Idle;
    END_IF
	_reset := FALSE;
	ClearCommands();
END_IF
jogForwardONS(CLK := jogForwardPB);
jogReverseONS(CLK := jogReversePB);
IF NOT enable THEN
    state := BAG_DELIVERY_STATES.Idle;
END_IF
delay();
_ready := (_mode = DEVICE_MODES.Auto) AND (NOT (state = BAG_DELIVERY_STATES.Fault) OR NOT (state = BAG_DELIVERY_STATES.Idle));

IF tensionFailONS.OSR AND NOT HMIData.enableDryCycle THEN
	bagTensionFault.Trigger();
END_IF

CASE state OF
    BAG_DELIVERY_STATES.Idle :                     
													IF _mode = DEVICE_MODES.Manual THEN 
														state := BAG_DELIVERY_STATES.Manual;
													ELSIF NOT iBagNotPresent OR HMIData.enableDryCycle THEN
														state := BAG_DELIVERY_STATES.Ready;
													//ELSIF iBagNotPresent AND (_amFeedToEye OR _amReverseBag) THEN
													ELSIF (_amFeedToEye OR _amReverseBag) THEN
														state := BAG_DELIVERY_STATES.FeedToEye;
														_amFeedToEye := FALSE;
													END_IF
													IF jogForwardONS.OSR THEN
														bagFeedMasterMotor.MoveDistance(distance := 30, 
                                                                                    acceleration := accelSetpoint, 
                                                                                    deceleration := decelSetpoint, 
                                                                                    velocity := REAL_TO_INT((1 * velocityMultiplier)));
													ELSIF jogReverseONS.OSR THEN
														bagFeedMasterMotor.MoveDistance(distance := -30, 
                                                                                    acceleration := accelSetpoint, 
                                                                                    deceleration := decelSetpoint, 
                                                                                    velocity := REAL_TO_INT((1 * velocityMultiplier)));
													ELSIF jogForwardONS.OSF OR jogReverseONS.OSF THEN
														bagFeedMasterMotor.Stop();
													END_IF
    
	BAG_DELIVERY_STATES.FeedToEye :					//Feed to photoeye if not present
													IF iBagNotPresent THEN
														bagFeedMasterMotor.MoveDistance(distance := feedToPhotoeyeSetpoint, 
                                                                                    acceleration := accelSetpoint, 
                                                                                    deceleration := decelSetpoint, 
                                                                                    velocity := REAL_TO_INT((feedToPhotoeyeSetpoint * velocityMultiplier)));
														state := BAG_DELIVERY_STATES.FeedingToEye;
													ELSE
														state := BAG_DELIVERY_STATES.SetTorqueMode;
													END_IF
													
													
	BAG_DELIVERY_STATES.FeedingToEye :				// Stop once photoeye seen
													delay.PT := T#3S;
													delay.IN := TRUE;
													IF NOT iBagNotPresent THEN
														bagFeedMasterMotor.Stop();
														state := BAG_DELIVERY_STATES.SetTorqueMode;
														delay.IN := FALSE;
													END_IF
													IF delay.Q THEN
														state := BAG_DELIVERY_STATES.Fault;
														noBagOverEye.Trigger();
														delay.IN := FALSE;
													END_IF
	
	BAG_DELIVERY_STATES.SetTorqueMode :				// Set torque following mode
													delay.PT := T#50MS;
													delay.IN := TRUE;
													IF delay.Q THEN
														bagFeedMasterMotor.SetRearMotorToTorqueMode();
														state := BAG_DELIVERY_STATES.Idle;	
														delay.IN := FALSE;
													END_IF
													
	
    BAG_DELIVERY_STATES.Reverse :                    // Reverse to break perf
                                                    bagFeedMasterMotor.MoveDistance(distance := reverseDistanceSetpoint, 
                                                                                    acceleration := TO_INT((ABS(reverseDistanceSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  accelPercent),
                                                                                    deceleration := TO_INT((ABS(reverseDistanceSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  decelPercent), 
                                                                                    velocity := REAL_TO_INT((reverseVelocitySetpoint * velocityMultiplier)));    
                                                        state := BAG_DELIVERY_STATES.Reversing;
                                                    
                                                    
    BAG_DELIVERY_STATES.Reversing :                    // Back up until we see the trailing edge of the bag
														 IF iBagNotPresent OR HMIData.enableDryCycle THEN
															delay.PT := T#10MS;
															delay.IN := TRUE;
															IF delay.Q THEN
																bagFeedMasterMotor.Stop();
																delay.IN := FALSE;
																delayForReverseFault.IN := FALSE;
																IF reverseToPrintheadRequired THEN
																	state := BAG_DELIVERY_STATES.ReverseToPrinthead;
																ELSE
																	state := BAG_DELIVERY_STATES.ReverseDone;
																END_IF
																
															END_IF
														ELSIF bagFeedMasterMotor.CommandAcknowledged AND NOT iBagNotPresent THEN
															delayForReverseFault.PT := T#3000MS;
															delayForReverseFault.IN := TRUE;
															IF delayForReverseFault.Q THEN
																reverseFault.Trigger();
																bagFeedMasterMotor.Stop();
															delayForReverseFault.IN := FALSE;
															state := BAG_DELIVERY_STATES.Fault; 
															END_IF
														END_IF
											
                                                  
													
	BAG_DELIVERY_STATES.ReverseToPrinthead :                    // Reverse to print head
                                                    delay.PT := T#50MS;
													delay.IN := TRUE;
													IF delay.Q THEN
														bagFeedMasterMotor.MoveDistanceFinal(distance := reverseToPrintHeadSetpoint, 
                                                                                    acceleration := TO_INT((ABS(reverseToPrintHeadSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  accelPercent),
                                                                                    deceleration := TO_INT((ABS(reverseToPrintHeadSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  decelPercent), 
                                                                                    velocity := REAL_TO_INT((reverseVelocitySetpoint * velocityMultiplier)));    
                                                    	state := BAG_DELIVERY_STATES.ReversingToPrintHead;
														delay.IN := FALSE;
													END_IF
													
													
	BAG_DELIVERY_STATES.ReversingToPrintHead :                    // Reverse to break perf
                                                   	delay.PT := T#50MS;
													delay.IN := TRUE;
													
													IF delay.Q THEN
														IF bagFeedMasterMotor.CommandAcknowledged AND bagFeedMasterMotor.InPosition THEN
                                                        	state := BAG_DELIVERY_STATES.ReverseDone;
                                                    	END_IF
														delay.IN := FALSE;
													END_IF
                                                    
    BAG_DELIVERY_STATES.ReverseDone :                // We don't print in semi auto or manual mode.  In auto mode if the printer is selected then we move to those states
                                                    IF _mode = DEVICE_MODES.SemiAuto OR _mode = DEVICE_MODES.Manual OR (_mode  = DEVICE_MODES.Auto AND autoFeedDelay.Q) THEN
                                                        IF bagFeedMasterMotor.CommandAcknowledged THEN
															state := BAG_DELIVERY_STATES.FeedBagOut;
                                                        	remainingLength := bagLengthSetpoint;
                                                        	_amFeedBagOut := FALSE;
														END_IF
														
                                                    ELSIF (_mode  = DEVICE_MODES.Auto AND _amWaitForPrinter) THEN
                                                        IF bagFeedMasterMotor.CommandAcknowledged THEN
															state := BAG_DELIVERY_STATES.WaitingForPrinter;
															IF reverseToPrintheadRequired THEN
																remainingLength := bagLengthSetpoint - (printLengthSetpoint + printOffsetSetpoint + printerExtraFeedLength);
															ELSE
																remainingLength := bagLengthSetpoint - (printLengthSetpoint + printOffsetSetpoint + printerExtraFeedLength);
															END_IF
															
															_amWaitForPrinter := FALSE;  
														END_IF  
                                                    END_IF
                                                        
                                                    
    BAG_DELIVERY_STATES.WaitingForPrinter :            // 
                                                    IF (_mode  = DEVICE_MODES.Auto AND _amPrinterReady) THEN
														IF printOffsetSetpoint <> 0 THEN
															state := BAG_DELIVERY_STATES.FeedToPrintOffset;
														ELSE
															state := BAG_DELIVERY_STATES.FedToPrintOffset;
														END_IF
                                                        
                                                        _amPrinterReady := FALSE;
                                                    END_IF
                                                        
    BAG_DELIVERY_STATES.FeedToPrintOffset :            // 
                                                    bagFeedMasterMotor.MoveDistance(distance := printOffsetSetpoint, 
                                                                                    acceleration := accelSetpoint, 
                                                                                    deceleration := decelSetpoint, 
                                                                                    velocity := REAL_TO_INT((feedVelocitySetpoint * velocityMultiplier)));    
                                                        state := BAG_DELIVERY_STATES.FeedingToPrintOffset;
                                                    
    BAG_DELIVERY_STATES.FeedingToPrintOffset :        // 
													delay.PT := checkMotorStatusDelay;
													delay.IN := TRUE;
													
													IF delay.Q THEN
														IF bagFeedMasterMotor.CommandAcknowledged AND bagFeedMasterMotor.InPosition THEN
                                                        	state := BAG_DELIVERY_STATES.FedToPrintOffset;
                                                    	END_IF
														delay.IN := FALSE;
													END_IF
                                                    
                                                    
    BAG_DELIVERY_STATES.FedToPrintOffset :            // 
                                                    IF (_mode  = DEVICE_MODES.Auto AND _amStartPrint) THEN
                                                        state := BAG_DELIVERY_STATES.FeedAtPrintSpeed;
                                                        _amStartPrint := FALSE;
                                                    END_IF
                                                    
    BAG_DELIVERY_STATES.FeedAtPrintSpeed :            // 
													delay.PT := delayForPrintFeed;
                                                    delay.IN := TRUE;
													
													IF delay.Q THEN
														bagFeedMasterMotor.MoveDistance(distance := printLengthSetpoint + printerExtraFeedLength, 
                                                                                    acceleration := accelSetpoint, 
                                                                                    deceleration := decelSetpoint, 
                                                                                    velocity := REAL_TO_INT((printVelocitySetpoint * velocityMultiplier)));    
                                                        state := BAG_DELIVERY_STATES.FeedingAtPrintSpeed;
														delay.IN := FALSE;
													END_IF
                                                    
    BAG_DELIVERY_STATES.FeedingAtPrintSpeed :        // 
													delay.PT := checkMotorStatusDelay;
													delay.IN := TRUE;
													IF delay.Q THEN
														IF bagFeedMasterMotor.CommandAcknowledged AND bagFeedMasterMotor.InPosition THEN
                                                        	state := BAG_DELIVERY_STATES.FedAtPrintSpeed;
                                                    	END_IF
														delay.IN := FALSE;
													END_IF
                                                   
                                                    
    BAG_DELIVERY_STATES.FedAtPrintSpeed :            // 
                                                    IF (_mode  = DEVICE_MODES.Auto AND _amPrinterDone) THEN
                                                        state := BAG_DELIVERY_STATES.FeedBagOut;
                                                        _amPrinterDone := FALSE;
                                                    END_IF
                                                    
    BAG_DELIVERY_STATES.FeedBagOut :                // Feed bag length out
                                                    //bagFeedMasterMotor.MoveDistanceFinal(distance := (remainingLength + sealOffsetSetpoint + (reverseToPrintHeadSetpoint*-1)), 
													IF reverseToPrintheadRequired THEN
														remainingLength := (remainingLength + sealBarToPrintHeadLength) - sealOffsetSetpoint;
													ELSE
														remainingLength := (remainingLength + sealBarToPrintHeadLength) - sealOffsetSetpoint + reverseToPrintHeadSetpoint;
													END_IF
													bagFeedMasterMotor.MoveDistanceFinal(distance := remainingLength, 
                                                                                        acceleration := accelSetpoint, 
                                                                                        deceleration := decelSetpoint, 
                                                                                        velocity := REAL_TO_INT((feedVelocitySetpoint * velocityMultiplier)));
                                                    state := BAG_DELIVERY_STATES.FeedingBagOut;    
    
    BAG_DELIVERY_STATES.FeedingBagOut :                // Wait until move is done
													delay.PT := checkMotorStatusDelay;
													delay.IN := TRUE;
													IF delay.Q THEN
														IF bagFeedMasterMotor.CommandAcknowledged AND bagFeedMasterMotor.InPosition THEN
                                                        state := BAG_DELIVERY_STATES.FedBagOut;
														
                                                    	END_IF
														delay.IN := FALSE;
													END_IF
                                                    
    
    BAG_DELIVERY_STATES.FedBagOut :                    // Go to the next ready state
                                                    IF _mode = DEVICE_MODES.Manual THEN 
                                                        state := BAG_DELIVERY_STATES.Manual;
                                                    ELSE
                                                        state := BAG_DELIVERY_STATES.Ready;
                                                    END_IF
													HMIData.driveRollerClean.SetCount(HMIData.driveRollerClean.count + TO_INT(bagLengthSetpoint));
                                                    Globals.bagDeliveryCycleCount := Globals.bagDeliveryCycleCount + 1;
    
    BAG_DELIVERY_STATES.Ready :                        IF (_mode = DEVICE_MODES.Auto AND _amReverseBag) OR _mode = DEVICE_MODES.SemiAuto THEN 
                                                        state := BAG_DELIVERY_STATES.Reverse;
                                                        ClearCommands();
                                                    END_IF 
													IF _amFeedToEye THEN
														state := BAG_DELIVERY_STATES.SetTorqueMode;
													END_IF
													_amFeedToEye := FALSE;
													IF iBagNotPresent AND NOT HMIData.enableDryCycle THEN 
														state := BAG_DELIVERY_STATES.Idle;
													END_IF
													IF jogForwardONS.OSR THEN
														bagFeedMasterMotor.MoveDistance(distance := 30, 
                                                                                    acceleration := accelSetpoint, 
                                                                                    deceleration := decelSetpoint, 
                                                                                    velocity := REAL_TO_INT((1 * velocityMultiplier)));
													ELSIF jogReverseONS.OSR THEN
														bagFeedMasterMotor.MoveDistance(distance := -30, 
                                                                                    acceleration := accelSetpoint, 
                                                                                    deceleration := decelSetpoint, 
                                                                                    velocity := REAL_TO_INT((1 * velocityMultiplier)));
													ELSIF jogForwardONS.OSF OR jogReverseONS.OSF THEN
														bagFeedMasterMotor.Stop();
													END_IF
    
    BAG_DELIVERY_STATES.Fault :                        ClearCommands();
													IF jogForwardONS.OSR THEN
														bagFeedMasterMotor.MoveDistance(distance := 30, 
                                                                                    acceleration := accelSetpoint, 
                                                                                    deceleration := decelSetpoint, 
                                                                                    velocity := REAL_TO_INT((1 * velocityMultiplier)));
													ELSIF jogReverseONS.OSR THEN
														bagFeedMasterMotor.MoveDistance(distance := -30, 
                                                                                    acceleration := accelSetpoint, 
                                                                                    deceleration := decelSetpoint, 
                                                                                    velocity := REAL_TO_INT((1 * velocityMultiplier)));
													ELSIF jogForwardONS.OSF OR jogReverseONS.OSF THEN
														bagFeedMasterMotor.Stop();
													END_IF
    
    BAG_DELIVERY_STATES.Manual :                    IF _mode = DEVICE_MODES.Auto THEN
														state := BAG_DELIVERY_STATES.Ready;	
													END_IF
													// Manually feed bags out
                                                    IF feedBagPB THEN
                                                        state := BAG_DELIVERY_STATES.Reverse;
                                                        feedBagPB := FALSE;
                                                    END_IF
                                                        
END_CASE