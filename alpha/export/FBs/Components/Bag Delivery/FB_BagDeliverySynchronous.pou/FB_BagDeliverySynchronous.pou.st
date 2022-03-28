(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_BagDeliverySynchronous EXTENDS FB_BaseComponent IMPLEMENTS IComponentStatus
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
	END_I: INT;
	_rotationTestBit : BOOL;
	_rotationTestBitAck : BOOL;
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: BagDeliveryFB
//    Description: This is the state machine for the bag delivery test rig
//    
//    Created by: Ben Hess
//    Created Date: Thursday, April 19, 2018

SUPER^();

//
delay();

//
delayForReverseFault();

//
autoFeedDelay(IN := _amFeedBagOut);

//
sealBarToPrintHeadLength := ABS(reverseToPrintHeadSetpoint) + 2.25;

//
IF (HMIData.baggerModelSelection = ModelSelection.Pro18) OR (HMIData.baggerModelSelection = ModelSelection.Pro18_02) THEN
	reverseToPrintHeadSetpoint := -1.25;
ELSE
	reverseToPrintHeadSetpoint := -1.0;
END_IF

//
bagFeedMasterMotor(
	ptrEIPInputs := ADR(bagDeliveryMotorInputs),
    ptrEIPOutputs := ADR(bagDeliveryMotorOutputs),
	placement := BAG_DELIVERY_MOTOR_PLACEMENT.Front,
    stepsPerInchSetpoint := stepsPerInchSetting,
	reversePolarity := FALSE, 
	defaultCurrentSetpoint := 1150, 
	commFail := bagFeedMasterMotorCommFailInput
);
bagFeedMasterMotor.Execute();

//
bagFeedRearMotor(
	ptrEIPInputs := ADR(bagRearMotorInputs),
    ptrEIPOutputs := ADR(bagRearMotorOutputs),
	placement := BAG_DELIVERY_MOTOR_PLACEMENT.Rear,
    stepsPerInchSetpoint := stepsPerInchSetting,
	reversePolarity := TRUE, 
	defaultCurrentSetpoint := 1150, 
	commFail := bagFeedRearMotorCommFailInput
);
bagFeedRearMotor.Execute();

//
IF enableONS.Q OR resetONS.Q THEN
    IF _mode = DEVICE_MODES.Manual THEN 
        state := BAG_DELIVERY_STATES.Manual;
    ELSE
        state := BAG_DELIVERY_STATES.Idle;
    END_IF
	_reset := FALSE;
	ClearCommands();
END_IF

//
jogForwardONS(CLK := jogForwardPB);
jogReverseONS(CLK := jogReversePB);

//
_ready := (_mode = DEVICE_MODES.Auto) AND (NOT (state = BAG_DELIVERY_STATES.Fault) OR NOT (state = BAG_DELIVERY_STATES.Idle));

//
tensionFailONS(CLK := iBagTensionFault);
IF tensionFailONS.OSR AND NOT HMIData.enableDryCycle THEN
	bagTensionFault.Trigger();
END_IF

//
IF NOT enable THEN
    state := BAG_DELIVERY_STATES.Idle;
END_IF

//
CASE state OF
    BAG_DELIVERY_STATES.Idle:                     
		IF _mode = DEVICE_MODES.Manual THEN 
			state := BAG_DELIVERY_STATES.Manual;
		ELSIF NOT iBagNotPresent OR HMIData.enableDryCycle THEN
			state := BAG_DELIVERY_STATES.Ready;
		ELSIF (_amFeedToEye OR _amReverseBag) THEN
			state := BAG_DELIVERY_STATES.FeedToEye;
			_amFeedToEye := FALSE;
		END_IF
		Jog();
    
	BAG_DELIVERY_STATES.FeedToEye:					
		// Feed to photoeye if not present
		IF iBagNotPresent THEN
			bagFeedMasterMotor.MoveDistance(
				distance := feedToPhotoeyeSetpoint, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((feedToPhotoeyeSetpoint * velocityMultiplier))
			);
			bagFeedRearMotor.MoveDistance(
				distance := feedToPhotoeyeSetpoint, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((feedToPhotoeyeSetpoint * velocityMultiplier))
			);
			state := BAG_DELIVERY_STATES.FeedToEyeSync;
		ELSE
			state := BAG_DELIVERY_STATES.SetTorqueMode;
		END_IF	
		
	BAG_DELIVERY_STATES.FeedToEyeSync:									
		IF bagFeedMasterMotor.ackRequest AND bagFeedRearMotor.ackRequest THEN
			bagFeedMasterMotor.ack := TRUE;
			bagFeedRearMotor.ack := TRUE;
			state := BAG_DELIVERY_STATES.FeedingToEye;
		END_IF
							
	BAG_DELIVERY_STATES.FeedingToEye:
		bagFeedMasterMotor.ack := FALSE;
		bagFeedRearMotor.ack := FALSE;				
		// Stop once photoeye seen
		delay.PT := T#3S;
		delay.IN := TRUE;
		IF NOT iBagNotPresent THEN
			bagFeedRearMotor.Stop();
			bagFeedMasterMotor.Stop();
			state := BAG_DELIVERY_STATES.SetTorqueMode;
			delay.IN := FALSE;
		END_IF
		IF delay.Q THEN
			state := BAG_DELIVERY_STATES.Fault;
			noBagOverEye.Trigger();
			delay.IN := FALSE;
		END_IF
	
	BAG_DELIVERY_STATES.SetTorqueMode :				
		bagFeedRearMotor.TriggerTorqueMode();
		state := BAG_DELIVERY_STATES.Idle;
													
    BAG_DELIVERY_STATES.Reverse :                   
		// Reverse to break perf
        bagFeedMasterMotor.MoveDistance(
			distance := reverseDistanceSetpoint, 
            acceleration := TO_INT((ABS(reverseDistanceSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  accelPercent),
            deceleration := TO_INT((ABS(reverseDistanceSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  decelPercent), 
            velocity := REAL_TO_INT((reverseVelocitySetpoint * velocityMultiplier))
		);
		  bagFeedRearMotor.MoveDistance(
			distance := reverseDistanceSetpoint, 
            acceleration := TO_INT((ABS(reverseDistanceSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  accelPercent),
            deceleration := TO_INT((ABS(reverseDistanceSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  decelPercent), 
            velocity := REAL_TO_INT((reverseVelocitySetpoint * velocityMultiplier))
		);      
        state := BAG_DELIVERY_STATES.ReverseSync;
	
	BAG_DELIVERY_STATES.ReverseSync:
		IF bagFeedMasterMotor.ackRequest AND bagFeedRearMotor.ackRequest THEN
			bagFeedMasterMotor.ack := TRUE;
			bagFeedRearMotor.ack := TRUE;
			state := BAG_DELIVERY_STATES.Reversing;
		END_IF
                                       
    BAG_DELIVERY_STATES.Reversing:
		bagFeedMasterMotor.ack := FALSE;
		bagFeedRearMotor.ack := FALSE;                   
		// Back up until we see the trailing edge of the bag
		IF iBagNotPresent OR HMIData.enableDryCycle THEN
			delay.PT := T#10MS;
			delay.IN := TRUE;
			IF delay.Q THEN
				bagFeedMasterMotor.Stop();
				bagFeedRearMotor.Stop();
				delay.IN := FALSE;
				delayForReverseFault.IN := FALSE;
				IF reverseToPrintheadRequired THEN
					state := BAG_DELIVERY_STATES.ReverseToPrinthead;
				ELSE
					state := BAG_DELIVERY_STATES.ReverseDone;
				END_IF
			END_IF
		ELSIF bagFeedMasterMotor.CommandAcknowledged AND bagFeedRearMotor.CommandAcknowledged AND NOT iBagNotPresent THEN
			delayForReverseFault.PT := T#3000MS;
			delayForReverseFault.IN := TRUE;
			IF delayForReverseFault.Q THEN
				reverseFault.Trigger();
				bagFeedMasterMotor.Stop();
				bagFeedRearMotor.Stop();
				delayForReverseFault.IN := FALSE;
				state := BAG_DELIVERY_STATES.Fault; 
			END_IF
		END_IF
																							
	BAG_DELIVERY_STATES.ReverseToPrinthead:                    
		// Reverse to print head
        delay.PT := T#50MS;
		delay.IN := TRUE;
		IF delay.Q THEN
			bagFeedMasterMotor.MoveDistanceFinal (
				distance := reverseToPrintHeadSetpoint, 
                acceleration := TO_INT((ABS(reverseToPrintHeadSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  accelPercent),
                deceleration := TO_INT((ABS(reverseToPrintHeadSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  decelPercent), 
                velocity := REAL_TO_INT((reverseVelocitySetpoint * velocityMultiplier))
			);
			bagFeedRearMotor.MoveDistanceFinal (
				distance := reverseToPrintHeadSetpoint, 
                acceleration := TO_INT((ABS(reverseToPrintHeadSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  accelPercent),
                deceleration := TO_INT((ABS(reverseToPrintHeadSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  decelPercent), 
                velocity := REAL_TO_INT((reverseVelocitySetpoint * velocityMultiplier))
			);      
        	state := BAG_DELIVERY_STATES.ReverseToPrintheadSync;
			delay.IN := FALSE;
		END_IF	

	BAG_DELIVERY_STATES.ReverseToPrintheadSync:
		//
		IF bagFeedMasterMotor.ackRequest AND bagFeedRearMotor.ackRequest THEN
			bagFeedMasterMotor.ack := TRUE;
			bagFeedRearMotor.ack := TRUE;
			state := BAG_DELIVERY_STATES.ReversingToPrintHead;
		END_IF								
													
	BAG_DELIVERY_STATES.ReversingToPrintHead:
		bagFeedMasterMotor.ack := FALSE;
		bagFeedRearMotor.ack := FALSE;	                    
		// Reverse to break perf
        delay.PT :=  T#50MS;
		delay.IN := TRUE;
		IF delay.Q THEN
			IF bagFeedMasterMotor.CommandAcknowledged AND bagFeedMasterMotor.InPosition
			   AND bagFeedRearMotor.CommandAcknowledged AND bagFeedRearMotor.InPosition THEN
            	state := BAG_DELIVERY_STATES.ReverseDone;
        	END_IF
			delay.IN := FALSE;
		END_IF
                                                    
    BAG_DELIVERY_STATES.ReverseDone:                
		// We don't print in semi auto or manual mode.  In auto mode if the printer is selected then we move to those states
        IF _mode = DEVICE_MODES.SemiAuto OR _mode = DEVICE_MODES.Manual OR (_mode  = DEVICE_MODES.Auto AND autoFeedDelay.Q) THEN
            IF bagFeedMasterMotor.CommandAcknowledged AND bagFeedRearMotor.CommandAcknowledged THEN
				state := BAG_DELIVERY_STATES.FeedBagOut;
            	remainingLength := bagLengthSetpoint;
            	_amFeedBagOut := FALSE;
			END_IF
			
        ELSIF (_mode  = DEVICE_MODES.Auto AND _amWaitForPrinter) THEN
            IF bagFeedMasterMotor.CommandAcknowledged AND bagFeedRearMotor.CommandAcknowledged THEN
				state := BAG_DELIVERY_STATES.WaitingForPrinter;
				IF reverseToPrintheadRequired THEN
					remainingLength := bagLengthSetpoint - (printLengthSetpoint + printOffsetSetpoint + printerExtraFeedLength);
				ELSE
					remainingLength := bagLengthSetpoint - (printLengthSetpoint + printOffsetSetpoint + printerExtraFeedLength);
				END_IF
				_amWaitForPrinter := FALSE;  
			END_IF  
        END_IF                                         
                                                    
    BAG_DELIVERY_STATES.WaitingForPrinter:            
		// 
        IF (_mode  = DEVICE_MODES.Auto AND _amPrinterReady) THEN
			IF printOffsetSetpoint <> 0 THEN
				state := BAG_DELIVERY_STATES.FeedToPrintOffset;
			ELSE
				state := BAG_DELIVERY_STATES.FedToPrintOffset;
			END_IF
            _amPrinterReady := FALSE;
        END_IF
                                                        
    BAG_DELIVERY_STATES.FeedToPrintOffset:            
		// 
        bagFeedMasterMotor.MoveDistance(
			distance := printOffsetSetpoint, 
            acceleration := accelSetpoint, 
            deceleration := decelSetpoint, 
            velocity := REAL_TO_INT((feedVelocitySetpoint * velocityMultiplier))
		);
		bagFeedRearMotor.MoveDistance(
			distance := printOffsetSetpoint, 
            acceleration := accelSetpoint, 
            deceleration := decelSetpoint, 
            velocity := REAL_TO_INT((feedVelocitySetpoint * velocityMultiplier))
		);     
        state := BAG_DELIVERY_STATES.FeedToPrintoffsetSync;
		
	BAG_DELIVERY_STATES.FeedToPrintoffsetSync:
		IF bagFeedMasterMotor.ackRequest AND bagFeedRearMotor.ackRequest THEN
			bagFeedMasterMotor.ack := TRUE;
			bagFeedRearMotor.ack := TRUE;
			state := BAG_DELIVERY_STATES.FeedingToPrintOffset;
		END_IF	
                                                    
    BAG_DELIVERY_STATES.FeedingToPrintOffset: 
		bagFeedMasterMotor.ack := FALSE;
		bagFeedRearMotor.ack := FALSE;	      
		// 
		delay.PT := checkMotorStatusDelay;
		delay.IN := TRUE;
		IF delay.Q THEN
			IF bagFeedMasterMotor.CommandAcknowledged AND bagFeedMasterMotor.InPosition AND 
			   bagFeedRearMotor.CommandAcknowledged AND bagFeedRearMotor.InPosition THEN
            	state := BAG_DELIVERY_STATES.FedToPrintOffset;
        	END_IF
			delay.IN := FALSE;
		END_IF
                                                                                 
    BAG_DELIVERY_STATES.FedToPrintOffset:           
		// 
        IF (_mode  = DEVICE_MODES.Auto AND _amStartPrint) THEN
            state := BAG_DELIVERY_STATES.FeedAtPrintSpeed;
            _amStartPrint := FALSE;
        END_IF
                                                    
    BAG_DELIVERY_STATES.FeedAtPrintSpeed:           
		// 
		delay.PT := delayForPrintFeed;
        delay.IN := TRUE;
		IF delay.Q THEN
			delay.IN := FALSE;
			bagFeedMasterMotor.MoveDistance(
				distance := printLengthSetpoint + printerExtraFeedLength, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((printVelocitySetpoint * velocityMultiplier))
			);
			bagFeedRearMotor.MoveDistance(
				distance := printLengthSetpoint + printerExtraFeedLength, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((printVelocitySetpoint * velocityMultiplier))
			);      
            state := BAG_DELIVERY_STATES.FeedAtPrintSpeedSync;
		END_IF
    
	BAG_DELIVERY_STATES.FeedAtPrintSpeedSync:
		//
		IF bagFeedMasterMotor.ackRequest AND bagFeedRearMotor.ackRequest THEN
			bagFeedMasterMotor.ack := TRUE;
			bagFeedRearMotor.ack := TRUE;
			state := BAG_DELIVERY_STATES.FeedingAtPrintSpeed;
		END_IF	
                      
    BAG_DELIVERY_STATES.FeedingAtPrintSpeed:  
		bagFeedMasterMotor.ack := FALSE;
		bagFeedRearMotor.ack := FALSE;	      
		// 
		delay.PT := checkMotorStatusDelay;
		delay.IN := TRUE;
		IF delay.Q THEN
			IF bagFeedMasterMotor.CommandAcknowledged AND bagFeedMasterMotor.InPosition AND
			   bagFeedRearMotor.CommandAcknowledged AND bagFeedRearMotor.InPosition THEN
            	state := BAG_DELIVERY_STATES.FedAtPrintSpeed;
        	END_IF
			delay.IN := FALSE;
		END_IF
                                                                                   
    BAG_DELIVERY_STATES.FedAtPrintSpeed:            
		// 
        IF (_mode  = DEVICE_MODES.Auto AND _amPrinterDone) THEN
            state := BAG_DELIVERY_STATES.FeedBagOut;
            _amPrinterDone := FALSE;
        END_IF
                                                    
    BAG_DELIVERY_STATES.FeedBagOut:                
		// Feed bag length out
		IF reverseToPrintheadRequired THEN
			remainingLength := (remainingLength + sealBarToPrintHeadLength) - sealOffsetSetpoint;
		ELSE
			remainingLength := (remainingLength + sealBarToPrintHeadLength) - sealOffsetSetpoint + reverseToPrintHeadSetpoint;
		END_IF
		bagFeedMasterMotor.MoveDistanceFinal(
			distance := remainingLength, 
            acceleration := accelSetpoint, 
            deceleration := decelSetpoint, 
            velocity := REAL_TO_INT((feedVelocitySetpoint * velocityMultiplier))
		);
		bagFeedRearMotor.MoveDistanceFinal(
			distance := remainingLength, 
            acceleration := accelSetpoint, 
            deceleration := decelSetpoint, 
            velocity := REAL_TO_INT((feedVelocitySetpoint * velocityMultiplier))
		);
        state := BAG_DELIVERY_STATES.FeedingBagOutSync; 

	BAG_DELIVERY_STATES.FeedingBagOutSync:
	    //
		IF bagFeedMasterMotor.ackRequest AND bagFeedRearMotor.ackRequest THEN
			bagFeedMasterMotor.ack := TRUE;
			bagFeedRearMotor.ack := TRUE;
			state := BAG_DELIVERY_STATES.FeedingBagOut;
		END_IF
    
    BAG_DELIVERY_STATES.FeedingBagOut: 
		bagFeedMasterMotor.ack := FALSE;
		bagFeedRearMotor.ack := FALSE;	            
		// Wait until move is done
		delay.PT := checkMotorStatusDelay;
		delay.IN := TRUE;
		IF delay.Q THEN
			IF bagFeedMasterMotor.CommandAcknowledged AND bagFeedMasterMotor.InPosition AND 
			   bagFeedRearMotor.CommandAcknowledged THEN
            	state := BAG_DELIVERY_STATES.FedBagOut;
        	END_IF
			delay.IN := FALSE;
		END_IF
                                                    
    BAG_DELIVERY_STATES.FedBagOut:                  
		// Go to the next ready state
        IF _mode = DEVICE_MODES.Manual THEN 
            state := BAG_DELIVERY_STATES.Manual;
        ELSE
            state := BAG_DELIVERY_STATES.Ready;
        END_IF
		HMIData.driveRollerClean.SetCount(HMIData.driveRollerClean.count + TO_INT(bagLengthSetpoint));
        Globals.bagDeliveryCycleCount := Globals.bagDeliveryCycleCount + 1;
    
    BAG_DELIVERY_STATES.Ready:                      
		IF (_mode = DEVICE_MODES.Auto AND _amReverseBag) OR _mode = DEVICE_MODES.SemiAuto THEN 
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
		Jog();
    
    BAG_DELIVERY_STATES.Fault :                        
		ClearCommands();
		Jog();
    
    BAG_DELIVERY_STATES.Manual:                     
		IF _mode = DEVICE_MODES.Auto THEN
			state := BAG_DELIVERY_STATES.Ready;	
		END_IF
		
		// Manually feed bags out
        IF feedBagPB THEN
            state := BAG_DELIVERY_STATES.Reverse;
            feedBagPB := FALSE;
        END_IF
                                                        
END_CASE