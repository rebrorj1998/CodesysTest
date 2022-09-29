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
	feedToPhotoeyeSetpoint : REAL := 2.0;
	useLastPrinterDelta : BOOL := TRUE;
	tensionFailONS : FB_ONS;
	bagFeedMasterMotorCommFailInput : BOOL;
	bagFeedRearMotorCommFailInput : BOOL;
	stepsPerInchSetting : INT;
	velocityMultiplier : REAL;
	rearMotorConfigVersion : CONFIG_VERSIONS;
	frontMotorConfigVersion : CONFIG_VERSIONS;
END_VAR
VAR_OUTPUT
    state : BAG_DELIVERY_STATES;    // Current state of bag delivery component
	reverseFault : FB_Fault(name := 'Reverse Fault');
	noBagOverEye : FB_Fault(name := 'No bag over Photoeye');
	bagTensionFault : FB_Fault(name := 'Bag Tension Fault');
	remainingLength : REAL;            // Remaining bag length after print
END_VAR
VAR
	 _nextState : BAG_DELIVERY_STATES;
    _delayTimer : TON := (PT := T#100MS);    // Delay for testing
	_jogForwardONS: FB_ONS;
	_jogReverseONS: FB_ONS;
	_delayForReverseFault : Standard.TON;
	_autoFeedDelay : TON := (PT := T#200MS);
	_sealBarToPrintHeadLength : REAL;
	_delayForPrintFeed : TIME := T#20MS;
	_printerExtraFeedLength : REAL := 0.25;
	_bagFeedFrontMotor : FB_AppliedMotionBagDeliveryMotor();
	_bagFeedRearMotor : FB_AppliedMotionBagDeliveryMotor();
	_accelPercent : REAL := 0.1;
	_decelPercent : REAL := 0.05;
    _amReverseBag : BOOL;            // Auto Mode - Reverse bag
    _amFeedBagOut : BOOL;            // Auto Mode - Feed new bag out
    _amWaitForPrinter : BOOL;        // Auto Mode - wait for printer
    _amPrinterReady : BOOL;            // Auto Mode - Printer is ready
    _amStartPrint : BOOL;            // Auto Mode - Start Printing
    _amPrinterDone : BOOL;             // Auto Mode - Printer is Done
	_amFeedToEye : BOOL;			  // Auto Mode - Feed Bag to Eye
	_reverseSpeedDistanceOffset : REAL;
	_reverseToPrintHeadSetpoint : REAL;
	_checkMotorStatusDelay : TIME := T#25MS;
	_tensionFault : BOOL;
	_interconnect : BAG_DELIVERY_IC;
	_jogging : BOOL;
	_joggingONS : Standard.F_TRIG;
	_syncingONS : Standard.F_TRIG; 
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: BagDeliveryFB
//    Description: This is the state machine for the bag delivery test rig
//    
//    Created by: Ben Hess
//    Created Date: Thursday, April 19, 2018

SUPER^();

//
_delayTimer();

//
_delayForReverseFault();

//
_autoFeedDelay(IN := _amFeedBagOut);

//
_sealBarToPrintHeadLength := ABS(_reverseToPrintHeadSetpoint) + 2.25;

//
IF (HMIData.baggerModelSelection = ModelSelection.Pro18) OR 
   (HMIData.baggerModelSelection = ModelSelection.Pro18_02) THEN
	_reverseToPrintHeadSetpoint := -1.25;
ELSE
	_reverseToPrintHeadSetpoint := -1.0;
END_IF

//
_bagFeedFrontMotor(
	ptrEIPInputs := ADR(bagDeliveryMotorInputs),
    ptrEIPOutputs := ADR(bagDeliveryMotorOutputs),
	interconnect := _interconnect,
	placement := BAG_DELIVERY_MOTOR_PLACEMENT.Front,
    stepsPerInchSetpoint := stepsPerInchSetting,
	reversePolarity := FALSE, 
	defaultCurrentSetpoint := 1150, 
	commFail := bagFeedMasterMotorCommFailInput
);
_bagFeedFrontMotor.Execute();

//
_bagFeedRearMotor(
	ptrEIPInputs := ADR(bagRearMotorInputs),
    ptrEIPOutputs := ADR(bagRearMotorOutputs),
	interconnect := _interconnect,
	placement := BAG_DELIVERY_MOTOR_PLACEMENT.Rear,
    stepsPerInchSetpoint := stepsPerInchSetting,
	defaultCurrentSetpoint := 1150, 
	commFail := bagFeedRearMotorCommFailInput
);
_bagFeedRearMotor.Execute();

CASE rearMotorConfigVersion OF
	CONFIG_VERSIONS.V_1_0,
	CONFIG_VERSIONS.V_1_1:
		_interconnect := BAG_DELIVERY_IC.CBL;
		_tensionFault := iBagTensionFault;
		_bagFeedRearMotor.reversePolarity := FALSE;
	CONFIG_VERSIONS.V_1_2, 
	CONFIG_VERSIONS.V_1_3:
		_interconnect := BAG_DELIVERY_IC.EIP;
		_tensionFault := _bagFeedRearMotor.tensionFault;
		_bagFeedRearMotor.reversePolarity := TRUE;
END_CASE
bagTensionFault.faultTrigger := _tensionFault AND NOT HMIData.enableDryCycle;

//
IF NOT enable THEN
    state := BAG_DELIVERY_STATES.Idle;
END_IF

//
IF enableONS.Q OR resetONS.Q THEN
    _reset := FALSE;
	_bagFeedRearMotor.Reset();
	_bagFeedFrontMotor.Reset();
	_nextState := BAG_DELIVERY_STATES.Idle; 
	IF _mode = DEVICE_MODES.Manual THEN 
        state := BAG_DELIVERY_STATES.Manual;
    ELSE
        state := BAG_DELIVERY_STATES.Idle;
    END_IF
	ClearCommands();
END_IF

//
_jogForwardONS(CLK := jogForwardPB);
_jogReverseONS(CLK := jogReversePB);
IF _jogging THEN
	IF _bagFeedFrontMotor.ackRequest AND _bagFeedRearMotor.ackRequest THEN
		_bagFeedFrontMotor.ack := TRUE;
		_bagFeedRearMotor.ack := TRUE;
	END_IF
END_IF

//
_joggingONS(CLK := _jogging);
_syncingONS(CLK := state = BAG_DELIVERY_STATES.Sync);
IF _joggingONS.Q OR _syncingONS.Q THEN
	_bagFeedFrontMotor.ack := FALSE;
	_bagFeedRearMotor.ack := FALSE;
END_IF

//
_ready := (_mode = DEVICE_MODES.Auto) AND (NOT (state = BAG_DELIVERY_STATES.Fault) OR NOT (state = BAG_DELIVERY_STATES.Idle));

//
CASE state OF
    BAG_DELIVERY_STATES.Idle:
		
		//                     
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
			_bagFeedFrontMotor.MoveDistance(
				distance := feedToPhotoeyeSetpoint, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((feedToPhotoeyeSetpoint * velocityMultiplier))
			);
			_bagFeedRearMotor.MoveDistance(
				distance := feedToPhotoeyeSetpoint, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((feedToPhotoeyeSetpoint * velocityMultiplier))
			);
			IF _bagFeedRearMotor.EIP THEN
				state := BAG_DELIVERY_STATES.Sync;
				_nextState := BAG_DELIVERY_STATES.FeedingToEye;
			ELSE
				state := BAG_DELIVERY_STATES.FeedingToEye;
			END_IF
		ELSE
			state := BAG_DELIVERY_STATES.SetTorqueMode;
		END_IF	
							
	BAG_DELIVERY_STATES.FeedingToEye:
				
		// Stop once photoeye seen
		_delayTimer.PT := T#3S;
		_delayTimer.IN := TRUE;
		IF NOT iBagNotPresent THEN
			_delayTimer.IN := FALSE;
			_bagFeedFrontMotor.Stop();
			state := BAG_DELIVERY_STATES.SetTorqueMode;
		END_IF
		IF _delayTimer.Q THEN
			state := BAG_DELIVERY_STATES.Fault;
			noBagOverEye.Trigger();
			_delayTimer.IN := FALSE;
		END_IF
	
	BAG_DELIVERY_STATES.SetTorqueMode:
	
		//
		IF NOT _bagFeedRearMotor.EIP THEN
			// Set torque following mode
			_delayTimer.PT := T#50MS;
			_delayTimer.IN := TRUE;
			IF _delayTimer.Q THEN
				_delayTimer.IN := FALSE;
				_bagFeedFrontMotor.TriggerTorqueMode();
				state := BAG_DELIVERY_STATES.Idle;	
			END_IF	
		ELSE
			_bagFeedRearMotor.TriggerTorqueMode();
			state := BAG_DELIVERY_STATES.SetTorqueValue;
		END_IF
		
	BAG_DELIVERY_STATES.SetTorqueValue:
		
		//
		IF _bagFeedRearMotor.commandSuccessful THEN
			_bagFeedRearMotor.SetTorque(torque := 60);
			state := BAG_DELIVERY_STATES.Idle;
		END_IF
													
    BAG_DELIVERY_STATES.Reverse:  
                 
		// Reverse to break perf
        _bagFeedFrontMotor.MoveDistance(
			distance := reverseDistanceSetpoint, 
            acceleration := TO_INT((ABS(reverseDistanceSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  _accelPercent),
            deceleration := TO_INT((ABS(reverseDistanceSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  _decelPercent), 
            velocity := REAL_TO_INT((reverseVelocitySetpoint * velocityMultiplier))
		);
		  _bagFeedRearMotor.MoveDistance(
			distance := reverseDistanceSetpoint, 
            acceleration := TO_INT((ABS(reverseDistanceSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  _accelPercent),
            deceleration := TO_INT((ABS(reverseDistanceSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  _decelPercent), 
            velocity := REAL_TO_INT((reverseVelocitySetpoint * velocityMultiplier))
		);    
		UpdateStateAfterSync(stt := BAG_DELIVERY_STATES.Reversing);
                                       
    BAG_DELIVERY_STATES.Reversing:
	
		// Back up until we see the trailing edge of the bag
		IF iBagNotPresent OR HMIData.enableDryCycle THEN
			_delayTimer.PT := T#10MS;
			_delayTimer.IN := TRUE;
			IF _delayTimer.Q THEN
				_delayTimer.IN := FALSE;
				_delayForReverseFault.IN := FALSE;
				_bagFeedFrontMotor.Stop();
				IF _interconnect = BAG_DELIVERY_IC.EIP THEN
					_bagFeedRearMotor.Stop();
				END_IF
				IF reverseToPrintheadRequired THEN
					state := BAG_DELIVERY_STATES.ReverseToPrinthead;
				ELSE
					state := BAG_DELIVERY_STATES.ReverseDone;
				END_IF
			END_IF
		ELSIF NOT iBagNotPresent THEN
			_delayForReverseFault.PT := T#1S;
			_delayForReverseFault.IN := TRUE;
			IF _delayForReverseFault.Q THEN
				reverseFault.Trigger();
				_bagFeedFrontMotor.Stop();
				IF _interconnect = BAG_DELIVERY_IC.EIP THEN
					_bagFeedRearMotor.Stop();
				END_IF
				_delayForReverseFault.IN := FALSE;
				state := BAG_DELIVERY_STATES.Fault; 
			END_IF
		END_IF
																							
	BAG_DELIVERY_STATES.ReverseToPrinthead:
                    
		// Reverse to print head
        _delayTimer.PT := T#50MS;
		_delayTimer.IN := TRUE;
		IF _delayTimer.Q THEN
			_delayTimer.IN := FALSE;
			_bagFeedFrontMotor.MoveDistanceFinal(
				distance := _reverseToPrintHeadSetpoint, 
                acceleration := TO_INT((ABS(_reverseToPrintHeadSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  _accelPercent),
                deceleration := TO_INT((ABS(_reverseToPrintHeadSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  _decelPercent), 
                velocity := REAL_TO_INT((reverseVelocitySetpoint * velocityMultiplier))
			);
			_bagFeedRearMotor.MoveDistanceFinal(
				distance := _reverseToPrintHeadSetpoint, 
                acceleration := TO_INT((ABS(_reverseToPrintHeadSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  _accelPercent),
                deceleration := TO_INT((ABS(_reverseToPrintHeadSetpoint) * Globals.STEPS_PER_INCH_20_DEGREE_BAG_DELIVERY) *  _decelPercent), 
                velocity := REAL_TO_INT((reverseVelocitySetpoint * velocityMultiplier))
			);
			UpdateStateAfterSync(stt := BAG_DELIVERY_STATES.ReversingToPrintHead);
		END_IF								
													
	BAG_DELIVERY_STATES.ReversingToPrintHead:
	
		// Reverse to break perf
        _delayTimer.PT :=  T#50MS;
		_delayTimer.IN := TRUE;
		IF _delayTimer.Q THEN
			_delayTimer.IN := FALSE;
			IF CommandAcknowledged AND InPosition THEN
            	state := BAG_DELIVERY_STATES.ReverseDone;
        	END_IF
		END_IF
                                                    
    BAG_DELIVERY_STATES.ReverseDone:   
             
		// We don't print in semi auto or manual mode.  In auto mode if the printer is selected then we move to those states
        IF _mode = DEVICE_MODES.SemiAuto OR _mode = DEVICE_MODES.Manual OR (_mode  = DEVICE_MODES.Auto AND _autoFeedDelay.Q) THEN
            IF CommandAcknowledged THEN
				state := BAG_DELIVERY_STATES.FeedBagOut;
            	remainingLength := bagLengthSetpoint;
            	_amFeedBagOut := FALSE;
			END_IF
        ELSIF (_mode  = DEVICE_MODES.Auto AND _amWaitForPrinter) THEN
            IF CommandAcknowledged THEN
				_amWaitForPrinter := FALSE; 
				state := BAG_DELIVERY_STATES.WaitingForPrinter;
				remainingLength := bagLengthSetpoint - (printLengthSetpoint + printOffsetSetpoint + _printerExtraFeedLength); 
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
        _bagFeedFrontMotor.MoveDistance(
			distance := printOffsetSetpoint, 
            acceleration := accelSetpoint, 
            deceleration := decelSetpoint, 
            velocity := REAL_TO_INT((feedVelocitySetpoint * velocityMultiplier))
		);
		_bagFeedRearMotor.MoveDistance(
			distance := printOffsetSetpoint, 
            acceleration := accelSetpoint, 
            deceleration := decelSetpoint, 
            velocity := REAL_TO_INT((feedVelocitySetpoint * velocityMultiplier))
		);
		UpdateStateAfterSync(stt := BAG_DELIVERY_STATES.FeedingToPrintOffset);
                                                    
    BAG_DELIVERY_STATES.FeedingToPrintOffset:       
		
		// 
		_delayTimer.PT := _checkMotorStatusDelay;
		_delayTimer.IN := TRUE;
		IF _delayTimer.Q THEN
			_delayTimer.IN := FALSE;
			IF CommandAcknowledged AND InPosition THEN
            	state := BAG_DELIVERY_STATES.FedToPrintOffset;
        	END_IF
		END_IF
                                                                                 
    BAG_DELIVERY_STATES.FedToPrintOffset:           
		
		// 
        IF (_mode  = DEVICE_MODES.Auto AND _amStartPrint) THEN
            state := BAG_DELIVERY_STATES.FeedAtPrintSpeed;
            _amStartPrint := FALSE;
        END_IF
                                                    
    BAG_DELIVERY_STATES.FeedAtPrintSpeed:           
		
		// 
		_delayTimer.PT := _delayForPrintFeed;
        _delayTimer.IN := TRUE;
		IF _delayTimer.Q THEN
			_delayTimer.IN := FALSE;
			_bagFeedFrontMotor.MoveDistance(
				distance := printLengthSetpoint + _printerExtraFeedLength, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((printVelocitySetpoint * velocityMultiplier))
			);
			_bagFeedRearMotor.MoveDistance(
				distance := printLengthSetpoint + _printerExtraFeedLength, 
                acceleration := accelSetpoint, 
                deceleration := decelSetpoint, 
                velocity := REAL_TO_INT((printVelocitySetpoint * velocityMultiplier))
			);      
			UpdateStateAfterSync(stt := BAG_DELIVERY_STATES.FeedingAtPrintSpeed);
		END_IF	
                      
    BAG_DELIVERY_STATES.FeedingAtPrintSpeed:

		// 
		_delayTimer.PT := _checkMotorStatusDelay;
		_delayTimer.IN := TRUE;
		IF _delayTimer.Q THEN
			_delayTimer.IN := FALSE;
			IF CommandAcknowledged AND InPosition THEN
            	state := BAG_DELIVERY_STATES.FedAtPrintSpeed;
        	END_IF
		END_IF
                                                                                   
    BAG_DELIVERY_STATES.FedAtPrintSpeed:            
		
		// 
        IF (_mode  = DEVICE_MODES.Auto AND _amPrinterDone) THEN
            state := BAG_DELIVERY_STATES.FeedBagOut;
            _amPrinterDone := FALSE;
        END_IF
                                                    
    BAG_DELIVERY_STATES.FeedBagOut:
		                
		// Feed bag length out
		remainingLength := (remainingLength + _sealBarToPrintHeadLength) - sealOffsetSetpoint;
		IF NOT reverseToPrintheadRequired THEN
			remainingLength := remainingLength + _reverseToPrintHeadSetpoint;
		END_IF
		_bagFeedFrontMotor.MoveDistanceFinal(
			distance := remainingLength, 
            acceleration := accelSetpoint, 
            deceleration := decelSetpoint, 
            velocity := REAL_TO_INT((feedVelocitySetpoint * velocityMultiplier))
		);
		_bagFeedRearMotor.MoveDistanceFinal(
			distance := remainingLength, 
            acceleration := accelSetpoint, 
            deceleration := decelSetpoint, 
            velocity := REAL_TO_INT((feedVelocitySetpoint * velocityMultiplier))
		);
		UpdateStateAfterSync(stt := BAG_DELIVERY_STATES.FeedingBagOut);
    
    BAG_DELIVERY_STATES.FeedingBagOut:   
          
		// Wait until move is done
		_delayTimer.PT := _checkMotorStatusDelay;
		_delayTimer.IN := TRUE;
		IF _delayTimer.Q THEN
			IF _bagFeedFrontMotor.InPosition AND CommandAcknowledged THEN
            	state := BAG_DELIVERY_STATES.FedBagOut;
        	END_IF
			_delayTimer.IN := FALSE;
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
		
	BAG_DELIVERY_STATES.Sync:
	
		// 
		IF _bagFeedFrontMotor.ackRequest AND _bagFeedRearMotor.ackRequest THEN
			_bagFeedFrontMotor.ack := TRUE;
			_bagFeedRearMotor.ack := TRUE;
			state := _nextState;
		END_IF	
    
    BAG_DELIVERY_STATES.Ready:  

		//                    
		IF (_mode = DEVICE_MODES.Auto AND _amReverseBag) OR _mode = DEVICE_MODES.SemiAuto THEN 
            state := BAG_DELIVERY_STATES.Reverse;
            ClearCommands();
        END_IF 
		IF _amFeedToEye THEN
			_amFeedToEye := FALSE;			
			state := BAG_DELIVERY_STATES.SetTorqueMode;
		END_IF
		IF iBagNotPresent AND NOT HMIData.enableDryCycle THEN 
			state := BAG_DELIVERY_STATES.Idle;
		END_IF
		Jog();
    
    BAG_DELIVERY_STATES.Fault:                        
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