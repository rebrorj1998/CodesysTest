

FUNCTION_BLOCK BagDeliveryFB EXTENDS BaseComponentFB IMPLEMENTS IComponentStatus
VAR_INPUT
    feedBagPB : BOOL;                // Manually Feed bag out
	jogForwardPB : BOOL;
	jogReversePB : BOOL;
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
END_VAR
VAR_OUTPUT
    state : BAG_DELIVERY_STATES;    // Current state of bag delivery component
	reverseFault : FB_Fault(name := 'Reverse Fault');
	noBagOverEye : FB_Fault(name := 'No bag over Photoeye');
	bagTensionFault : FB_Fault(name := 'Bag Tension Fault');
END_VAR
VAR
    delay : TON := (PT := T#100MS);    // Delay for testing
	jogForwardONS: FB_ONS;
	jogReverseONS: FB_ONS;
	delayForReverseFault : Standard.TON;
	autoFeedDelay : TON := (PT := T#200MS);
	sealBarToPrintHeadLength : REAL;
    bagsCurrentlyFed  :INT;            // Bags currently fed for testing
    remainingLength : REAL;            // Remaining bag length after print
	delayForPrintFeed : TIME := T#250MS;
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
END_VAR

//    Function Block: BagDeliveryFB
//    Description: This is the state machine for the bag delivery test rig
//    
//    Created by: Ben Hess
//    Created Date: Thursday, April 19, 2018

SUPER^();
tensionFailONS(CLK := iBagTensionFault);

delay();
delayForReverseFault();
autoFeedDelay(IN := _amFeedBagOut);
// This is the master Applied Motion motor
IF useLastPrinterDelta THEN
	IF Globals.lastPrinterDelta >= T#90MS THEN
		delayForPrintFeed := Globals.lastPrinterDelta - T#80MS;
	ELSE
		delayForPrintFeed := T#0MS;
	END_IF
END_IF
bagLengthSetpoint := HMIData.bagLength;
printVelocitySetpoint := HMIData.printSpeed;
sealOffsetSetpoint := HMIData.bagSkirtLength;
printOffsetSetpoint := HMIData.printOffset;
sealBarToPrintHeadLength := ABS(reverseToPrintHeadSetpoint) + 2.25;
printLengthSetpoint := HMIData.printLength;
reverseVelocitySetpoint := TO_INT(HMIData.bagReverseSpeed);
feedVelocitySetpoint := TO_INT(HMIData.bagForwardSpeed);

(*bagFeedMasterMotor(modbusInputParameters := BagDeliverMasterMotorModbusInputs, 
                    stepsPerInchSetpoint := Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY, 
                    reversePolarity := FALSE, 
                    slave := Bag_Delivery_Master_Motor);*)
bagFeedMasterMotor(ptrEIPInputs := ADR(bagDeliveryMotorInputs),
                ptrEIPOutputs := ADR(bagDeliveryMotorOutputs),
                stepsPerInchSetpoint := Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY,
                faultHandler := PRG_Bagger.faultHandler,
				reversePolarity := FALSE, 
				defaultCurrentSetpoint := 1150, 
				commFail := Bag_Delivery_EIP_Motor.udiState <> 4);
bagFeedMasterMotor.Execute();

bagFeedRearMotor(ptrEIPInputs := ADR(bagRearMotorInputs),
                ptrEIPOutputs := ADR(bagRearMotorOutputs),
                stepsPerInchSetpoint := Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY,
                faultHandler := PRG_Bagger.faultHandler,
				reversePolarity := FALSE, 
				defaultCurrentSetpoint := 1150, 
				commFail := Bag_Delivery_Rear_Motor.udiState <> 4);
bagFeedRearMotor.Execute();

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

IF tensionFailONS.OSR THEN
	bagTensionFault.Trigger();
END_IF

CASE state OF
    BAG_DELIVERY_STATES.Idle :                     
													IF _mode = DEVICE_MODES.Manual THEN 
														state := BAG_DELIVERY_STATES.Manual;
													ELSIF NOT iBagNotPresent OR Globals.enableDryCycle THEN
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
                                                                                    velocity := REAL_TO_INT((1 * Globals.VELOCITY_IPS_MULTIPLIER_20_DEGREE_BAG_DELIVERY)));
													ELSIF jogReverseONS.OSR THEN
														bagFeedMasterMotor.MoveDistance(distance := -30, 
                                                                                    acceleration := accelSetpoint, 
                                                                                    deceleration := decelSetpoint, 
                                                                                    velocity := REAL_TO_INT((1 * Globals.VELOCITY_IPS_MULTIPLIER_20_DEGREE_BAG_DELIVERY)));
													ELSIF jogForwardONS.OSF OR jogReverseONS.OSF THEN
														bagFeedMasterMotor.Stop();
													END_IF
    
	BAG_DELIVERY_STATES.FeedToEye :					//Feed to photoeye if not present
													IF iBagNotPresent THEN
														bagFeedMasterMotor.MoveDistance(distance := feedToPhotoeyeSetpoint, 
                                                                                    acceleration := accelSetpoint, 
                                                                                    deceleration := decelSetpoint, 
                                                                                    velocity := REAL_TO_INT((feedToPhotoeyeSetpoint * Globals.VELOCITY_IPS_MULTIPLIER_20_DEGREE_BAG_DELIVERY)));
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
                                                                                    velocity := REAL_TO_INT((reverseVelocitySetpoint * Globals.VELOCITY_IPS_MULTIPLIER_20_DEGREE_BAG_DELIVERY)));    
                                                        state := BAG_DELIVERY_STATES.Reversing;
                                                    
                                                    
    BAG_DELIVERY_STATES.Reversing :                    // Back up until we see the trailing edge of the bag
														 IF iBagNotPresent OR Globals.enableDryCycle THEN
															delay.PT := T#10MS;
															delay.IN := TRUE;
															IF delay.Q THEN
																bagFeedMasterMotor.Stop();
																delay.IN := FALSE;
																delayForReverseFault.IN := FALSE;
																state := BAG_DELIVERY_STATES.ReverseToPrinthead;
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
                                                                                    velocity := REAL_TO_INT((reverseVelocitySetpoint * Globals.VELOCITY_IPS_MULTIPLIER_20_DEGREE_BAG_DELIVERY)));    
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
															remainingLength := bagLengthSetpoint - (printLengthSetpoint + printOffsetSetpoint + printerExtraFeedLength);
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
                                                                                    velocity := REAL_TO_INT((feedVelocitySetpoint * Globals.VELOCITY_IPS_MULTIPLIER_20_DEGREE_BAG_DELIVERY)));    
                                                        state := BAG_DELIVERY_STATES.FeedingToPrintOffset;
                                                    
    BAG_DELIVERY_STATES.FeedingToPrintOffset :        // 
													delay.PT := T#50MS;
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
                                                                                    velocity := REAL_TO_INT((printVelocitySetpoint * Globals.VELOCITY_IPS_MULTIPLIER_20_DEGREE_BAG_DELIVERY)));    
                                                        state := BAG_DELIVERY_STATES.FeedingAtPrintSpeed;
														delay.IN := FALSE;
													END_IF
                                                    
    BAG_DELIVERY_STATES.FeedingAtPrintSpeed :        // 
													delay.PT := T#50MS;
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
													bagFeedMasterMotor.MoveDistanceFinal(distance := (remainingLength + sealBarToPrintHeadLength) - sealOffsetSetpoint, 
                                                                                        acceleration := accelSetpoint, 
                                                                                        deceleration := decelSetpoint, 
                                                                                        velocity := REAL_TO_INT((feedVelocitySetpoint * Globals.VELOCITY_IPS_MULTIPLIER_20_DEGREE_BAG_DELIVERY)));
                                                    state := BAG_DELIVERY_STATES.FeedingBagOut;    
    
    BAG_DELIVERY_STATES.FeedingBagOut :                // Wait until move is done
													delay.PT := T#50MS;
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
													IF iBagNotPresent AND NOT Globals.enableDryCycle THEN 
														state := BAG_DELIVERY_STATES.Idle;
													END_IF
													IF jogForwardONS.OSR THEN
														bagFeedMasterMotor.MoveDistance(distance := 30, 
                                                                                    acceleration := accelSetpoint, 
                                                                                    deceleration := decelSetpoint, 
                                                                                    velocity := REAL_TO_INT((1 * Globals.VELOCITY_IPS_MULTIPLIER_20_DEGREE_BAG_DELIVERY)));
													ELSIF jogReverseONS.OSR THEN
														bagFeedMasterMotor.MoveDistance(distance := -30, 
                                                                                    acceleration := accelSetpoint, 
                                                                                    deceleration := decelSetpoint, 
                                                                                    velocity := REAL_TO_INT((1 * Globals.VELOCITY_IPS_MULTIPLIER_20_DEGREE_BAG_DELIVERY)));
													ELSIF jogForwardONS.OSF OR jogReverseONS.OSF THEN
														bagFeedMasterMotor.Stop();
													END_IF
    
    BAG_DELIVERY_STATES.Fault :                        ClearCommands();
													IF jogForwardONS.OSR THEN
														bagFeedMasterMotor.MoveDistance(distance := 30, 
                                                                                    acceleration := accelSetpoint, 
                                                                                    deceleration := decelSetpoint, 
                                                                                    velocity := REAL_TO_INT((1 * Globals.VELOCITY_IPS_MULTIPLIER_20_DEGREE_BAG_DELIVERY)));
													ELSIF jogReverseONS.OSR THEN
														bagFeedMasterMotor.MoveDistance(distance := -30, 
                                                                                    acceleration := accelSetpoint, 
                                                                                    deceleration := decelSetpoint, 
                                                                                    velocity := REAL_TO_INT((1 * Globals.VELOCITY_IPS_MULTIPLIER_20_DEGREE_BAG_DELIVERY)));
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

METHOD AutoPrinterDone
VAR_INPUT
END_VAR

_amPrinterDone := TRUE;

PROPERTY Ready : BOOL


PROPERTY Mode : DEVICE_MODES


METHOD AutoFeedToEye
VAR_INPUT
END_VAR

_amFeedToEye := TRUE;

METHOD AutoWaitForPrinter
VAR_INPUT
END_VAR

_amWaitForPrinter := TRUE;

METHOD AutoReverseBag
VAR_INPUT
END_VAR

_amReverseBag := TRUE;

METHOD PRIVATE ClearCommands
VAR_INPUT
END_VAR

_amFeedBagOut := FALSE;
_amReverseBag := FALSE;
_amPrinterDone := FALSE;
_amPrinterReady := FALSE;
_amWaitForPrinter := FALSE;
_amStartPrint := FALSE;
//_amFeedToEye := FALSE;

METHOD AutoPrinterReady
VAR_INPUT
END_VAR

_amPrinterReady := TRUE;

METHOD AutoFeedBagOut
VAR_INPUT
END_VAR

_amFeedBagOut := TRUE;

METHOD AutoStartPrintFeed
VAR_INPUT
END_VAR

_amStartPrint := TRUE;