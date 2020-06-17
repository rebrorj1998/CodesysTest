(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
METHOD Executing
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//	Method: EM01_Bagger_Automode.Executing()
//	Description: Executing is the state in which the machine is producing bags.  In this state, the bagger is homed and ready to initiate a cycle any time.  
//				 In normal operation, the machine should be in this state most of the time
//				 The logic below is generic and coded to interfaces for each component	
//	Created by: Ben Hess
//	Created Date: Tuesday, March 26, 2019
currentBaggerState := 'Executing';

IF NOT __ISVALIDREF(bagger) THEN
	RETURN;
END_IF

// Clear starting done status because if we're here starting state is complete.
_startingDone := FALSE;

IF resetTriggered THEN
	state := HEAD_STATES.Idle;
	sealAndSeparateSubState := SEAL_SEPARATE_STATES.Idle;
	releaseAndFeedSubState := RELEASE_FEED_STATES.Idle;
	bagOpenSubState := BAG_OPEN_ASSIST_STATES.Idle;
END_IF
// Run Cycle timer for machine cycle
cycleTimer();
vacuumDwellTimer(PT := bagger.vacuumDwell);
// State machine for overall head states
CASE state OF
    HEAD_STATES.Idle :                              // Start cycle
													
                                                    IF bagger.StartCycleRequest THEN
														baggerCycleActive := TRUE;
														bagger.StartCycleRequest := FALSE;
														cycleComplete := FALSE;
														cycleTimer.IN := TRUE;
														_logger.AddLogItem('Cycle Started');
														SetHeadState(HEAD_STATES.SealAndSeparateBag);
													END_IF
													
													IF MoveRequested (bagger.pressureBar) THEN
														SetHeadState(HEAD_STATES.MovePassthrough);
													END_IF
													
	HEAD_STATES.MovePassthrough : 					//
													PostHomeMoveIfNeeded(bagger.pressureBar);
													SetHeadState(HEAD_STATES.MovingPassthrough);
	
													
    HEAD_STATES.MovingPassthrough :                 //
													IF NOT MoveRequested (bagger.pressureBar) THEN
														SetHeadState(HEAD_STATES.MovedPassthrough);
													END_IF
                                  
	HEAD_STATES.MovedPassthrough : 					//
													SetHeadState(HEAD_STATES.Idle);
                  
    HEAD_STATES.SealAndSeparateBag :                // Begin Seal and Separate State machine
                                                    SetSealSeparateState(SEAL_SEPARATE_STATES.MoveJawIn);
													SetHeadState(HEAD_STATES.SealingAndSeparatingBag);
                                                    
                
    HEAD_STATES.SealingAndSeparatingBag :          //
													IF sealAndSeparateSubState = SEAL_SEPARATE_STATES.Done THEN
														SetHeadState(HEAD_STATES.SealedAndSeparatedBag);
														SetSealSeparateState(SEAL_SEPARATE_STATES.Idle);
                                                    END_IF    

    HEAD_STATES.SealedAndSeparatedBag :             //
													SetHeadState(HEAD_STATES.ReleaseAndFeedBag);                                    
                                                    
    HEAD_STATES.ReleaseAndFeedBag :                 // Open the jaw and release the bag
													SetReleaseFeedState(RELEASE_FEED_STATES.MoveJawOutAndFeedBag);
                                                    SetHeadState(HEAD_STATES.ReleasingAndFeedingBag);
                                                    
    HEAD_STATES.ReleasingAndFeedingBag :            // 
                                                    IF releaseAndFeedSubState = RELEASE_FEED_STATES.Done THEN
                                                        SetHeadState(HEAD_STATES.ReleasedAndFedBag);
                                                        SetReleaseFeedState(RELEASE_FEED_STATES.Idle);
                                                    END_IF
                                                    
    HEAD_STATES.ReleasedAndFedBag :                 // Start opening bag if bag open assist is enabled, otherwise end cycle now
													IF bagger.bagOpenAssistEnabled THEN
														SetHeadState(HEAD_STATES.OpenBag);
													ELSE
														SetHeadState(HEAD_STATES.OpenedBag);
													END_IF
                                                        
                                                         
                                                    
                                
    HEAD_STATES.OpenBag :                            // Close jaw to grab the bag
                                                    SetBagOpenState(BAG_OPEN_ASSIST_STATES.MoveJawIn);
                                                    SetHeadState(HEAD_STATES.OpeningBag);
                                                    
                                                    
    HEAD_STATES.OpeningBag :                        // Open jaw and grab onto the bag.  Feed a new bag out if missed
                                                    IF bagOpenSubState = BAG_OPEN_ASSIST_STATES.Done THEN
                                                        SetHeadState(HEAD_STATES.OpenedBag);
                                                        SetBagOpenState(BAG_OPEN_ASSIST_STATES.Idle);
													ELSIF bagOpenSubState = BAG_OPEN_ASSIST_STATES.FeedNewBag THEN
														SetHeadState(HEAD_STATES.SealAndSeparateBag);
														SetBagOpenState(BAG_OPEN_ASSIST_STATES.Idle);
                                                    END_IF
                                                    
    HEAD_STATES.OpenedBag :                         // End cycle           
													IF bagger.barcodeVerifier.OptionActive THEN
														IF bagger.barcodeVerifier.VerificationFault THEN
															bagger.barcodeVerificationFailed.Trigger();
														ELSIF bagger.barcodeVerifier.GoodRead OR bagger.barcodeVerifier.BadRead THEN
															baggerCycleActive := FALSE;
															SetHeadState(HEAD_STATES.Idle);
															cycleTime := (TIME_TO_REAL(cycleTimer.ET) / 1000); 
															cycleTimer.IN := FALSE;
															_logger.AddLogItem(CONCAT('Cycle Complete in ',TO_STRING(cycleTime)));
														END_IF 
													ELSE
														baggerCycleActive := FALSE;
														SetHeadState(HEAD_STATES.Idle);
														cycleTime := (TIME_TO_REAL(cycleTimer.ET) / 1000); 
														cycleTimer.IN := FALSE;
														_logger.AddLogItem(CONCAT('Cycle Complete in ',TO_STRING(cycleTime)));
													END_IF
													cycleComplete := TRUE;
													 
                                                    
                                                  
    //HEAD_STATES.Fault :                                
                                                    
END_CASE



CASE sealAndSeparateSubState OF
    //SEAL_SEPARATE_STATES.Idle : 
        
    SEAL_SEPARATE_STATES.MoveJawIn :                // Perform actions as enabled - close jaw and move flatteners out. If jaw is disabled then go right to reverse bag
                                                    IF bagger.sealFlatteners.OptionActive THEN
														bagger.sealFlatteners.ToSeal();
													END_IF
													IF bagger.IBD.OptionActive THEN
														bagger.IBD.MoveInToDeflate();
													END_IF
                                                    bagger.pressureBar.Close();
													SetSealSeparateState(SEAL_SEPARATE_STATES.MovingJawIn);
                                                    
                                                    
                                                    
    SEAL_SEPARATE_STATES.MovingJawIn :              // If Jaw is in and flatteners out then move on
                                                   	IF (NOT bagger.sealFlatteners.OptionActive OR bagger.sealFlatteners.InPosition)
														AND bagger.pressureBar.IsFullyClosed THEN    
															SetSealSeparateState(SEAL_SEPARATE_STATES.MovedJawIn);
                                                    END_IF
                                                                
    SEAL_SEPARATE_STATES.MovedJawIn :               // Seal bag now if separate before seal option selected
													IF NOT bagger.separateBeforeSealEnabled THEN
														bagger.sealer.BeginSealing();
													END_IF
													SetSealSeparateState(SEAL_SEPARATE_STATES.ReverseBag);
                                                    
    SEAL_SEPARATE_STATES.ReverseBag :               // Start reversing bag to seal
													bagger.bagDelivery.ReverseToSeparate();
													SetSealSeparateState(SEAL_SEPARATE_STATES.ReversingBag);
													
                                                                    
    SEAL_SEPARATE_STATES.ReversingBag :             // 
                                                    IF bagger.bagDelivery.BagSeparated 
														AND (bagger.sealer.SealComplete OR bagger.separateBeforeSealEnabled)
                                                        THEN
															SetSealSeparateState(SEAL_SEPARATE_STATES.Reversedbag);
                                                    END_IF
													
    SEAL_SEPARATE_STATES.Reversedbag :              // 
                                                    IF bagger.separateBeforeSealEnabled THEN
														SetSealSeparateState(SEAL_SEPARATE_STATES.SealBag);
													ELSE 
														SetSealSeparateState(SEAL_SEPARATE_STATES.Done);
													END_IF
													
	SEAL_SEPARATE_STATES.SealBag:					
													bagger.sealer.BeginSealing();
													SetSealSeparateState(SEAL_SEPARATE_STATES.SealingBag);
													
													
	SEAL_SEPARATE_STATES.SealingBag:				//
													IF bagger.sealer.SealComplete THEN
														SetSealSeparateState(SEAL_SEPARATE_STATES.Done);
														IF bagger.IBD.OptionActive THEN
															bagger.IBD.MoveOut();
														END_IF
													END_IF
																												
                                                    
    //SEAL_SEPARATE_STATES.Done :                   // 
                                                    
                                    
    //SEAL_SEPARATE_STATES.Fault :					//
END_CASE


CASE releaseAndFeedSubState OF
    //RELEASE_FEED_STATES.Idle :                    //
                                                        
    RELEASE_FEED_STATES.MoveJawOutAndFeedBag :        	
													bagger.bagOpenFingers.ReleaseBag();
													bagger.sealFlatteners.ToBagFeed();
													bagger.pressureBar.Open();
													bagger.loadPlate.BeginDischarge();	
													discharge.TakeAwayBag(THIS^);
													releaseAndFeedSubState := RELEASE_FEED_STATES.WaitForOKFromDischarge;	
													// If printer is enabled then perform printer operation of bag delivery, otherwise just feed new bag out.
													IF NOT bagger.printer.OptionActive THEN
														IF NOT bagger.pressureBar.IsFullyClosed THEN
															bagger.bagDelivery.FeedBagOut();
															SetReleaseFeedState(RELEASE_FEED_STATES.MovingJawOutAndFeedingBag);
														END_IF
													ELSE 
														SetReleaseFeedState(RELEASE_FEED_STATES.WaitForPrinter);
													END_IF
														

    RELEASE_FEED_STATES.WaitForOKFromDischarge :   	// Wait for EM02 - Discharge to give OK to feed bag signal
													IF discharge.OKToFeedBag THEN
														IF NOT bagger.printer.OptionActive THEN
															bagger.bagDelivery.FeedBagOut();
															SetReleaseFeedState(RELEASE_FEED_STATES.MovingJawOutAndFeedingBag);
														ELSE 
															SetReleaseFeedState(RELEASE_FEED_STATES.WaitForPrinter);
														END_IF   
													END_IF
													                                         
    
    RELEASE_FEED_STATES.WaitForPrinter :            // Data Ready means the printer has a label and we're all set to print
                                                    IF bagger.printer.HasLabel AND NOT bagger.pressureBar.IsFullyClosed THEN
														SetReleaseFeedState(RELEASE_FEED_STATES.FeedToOffset);
                                                    END_IF
                                                    
    RELEASE_FEED_STATES.FeedToOffset :              // Start feeding to the print offset
                                                    bagger.bagDelivery.FeedToPrintOffset();
													SetReleaseFeedState(RELEASE_FEED_STATES.FeedingToOffset);
                                                        
    RELEASE_FEED_STATES.FeedingToOffset :            // Once offset done start printing
                                                    IF bagger.bagDelivery.ReadyForPrint THEN
														bagger.printer.BeginPrinting();
														bagger.bagDelivery.FeedAtPrintSpeed();
														IF bagger.barcodeVerifier.OptionActive THEN
															bagger.barcodeVerifier.Trigger();
														END_IF
														SetReleaseFeedState(RELEASE_FEED_STATES.StartPrinting);
                                                    END_IF                                            
    
    RELEASE_FEED_STATES.StartPrinting :             // Printer starts print cycle and bag delivery starts moving at print speed
													
													SetReleaseFeedState(RELEASE_FEED_STATES.Printing);

    //RELEASE_FEED_STATES.SendPrintSignal:            //                                     

    RELEASE_FEED_STATES.Printing :                  // Wait for print to finish
                                                    IF bagger.printer.PrintDone THEN
														SetReleaseFeedState(RELEASE_FEED_STATES.StopPrinting);
														//bagger.bagDelivery.FeedBagOut();
                                                    END_IF
                                                    
    RELEASE_FEED_STATES.StopPrinting :              // Tell bag delivery it's okay to feed out the rest of the bag and the printer that it can prep itself for the next print
                                                   
													SetReleaseFeedState(RELEASE_FEED_STATES.MovingJawOutAndFeedingBag);
                                                                                
                                                                                                            
    RELEASE_FEED_STATES.MovingJawOutAndFeedingBag : // 
													IF (bagger.sealFlatteners.InPosition OR NOT bagger.sealFlatteners.OptionActive) 
                                                        AND bagger.pressureBar.IsFullyOpen 
														AND bagger.bagDelivery.BagFeedDone
                                                        THEN
															SetReleaseFeedState(RELEASE_FEED_STATES.MovedJawOutAndFedBag);
                                                    END_IF
                                                    
    RELEASE_FEED_STATES.MovedJawOutAndFedBag :        
													SetReleaseFeedState(RELEASE_FEED_STATES.Done);
    //RELEASE_FEED_STATES.Done :						
    //RELEASE_FEED_STATES.Fault :						
END_CASE



CASE bagOpenSubState OF
    BAG_OPEN_ASSIST_STATES.Idle :                    // 
                                                    
                                                    
                                                    
    BAG_OPEN_ASSIST_STATES.MoveJawIn :                // Close jaw against bag. In the future we may also start vacuum here
                                                    bagger.pressureBar.Close();
													SetBagOpenState(BAG_OPEN_ASSIST_STATES.MovingJawIn);       
                                                    
                                                    
    BAG_OPEN_ASSIST_STATES.MovingJawIn :            // Move on once jaw is closed
                                                    IF bagger.pressureBar.IsFullyClosed THEN
														IF bagger.vacuumBagOpen.OptionActive THEN
															bagger.vacuumBagOpen.StartVacuum();
														END_IF
														SetBagOpenState(BAG_OPEN_ASSIST_STATES.MovedJawIn);      
                                                    END_IF
                                                    
                                                    
    BAG_OPEN_ASSIST_STATES.MovedJawIn :             // Hold onto the bag with vacuum to build suction
													vacuumDwellTimer.IN := TRUE;
													IF (vacuumDwellTimer.Q OR NOT bagger.vacuumBagOpen.OptionActive) THEN
														vacuumDwellTimer.IN := FALSE;
														SetBagOpenState(BAG_OPEN_ASSIST_STATES.MoveJawOut);
													END_IF
                                                                   
                                                    
                                                    
    BAG_OPEN_ASSIST_STATES.MoveJawOut :             // Open the jaw and move seal flatteners in and to bag holding
                                                    bagger.pressureBar.Open();
													SetBagOpenState(BAG_OPEN_ASSIST_STATES.MovingJawOutAndGrab);
                                                    
                                                    
    BAG_OPEN_ASSIST_STATES.MovingJawOutAndGrab :    	// 													
														IF bagger.bagOpenFingers.OptionActive THEN
															bagger.bagOpenFingers.GrabBag();
															IF bagger.bagOpenSensorEnabled THEN
																SetBagOpenState(BAG_OPEN_ASSIST_STATES.CheckForSuccessfulBagGrab);
															ELSE
																SetBagOpenState(BAG_OPEN_ASSIST_STATES.BagOpened);
															END_IF
														ELSE
															SetBagOpenState(BAG_OPEN_ASSIST_STATES.BagOpened);
														END_IF
													  

	BAG_OPEN_ASSIST_STATES.CheckForSuccessfulBagGrab : 	//
														IF bagger.CurrentBagOpenRetryCount < bagger.bagOpenRetrySetting THEN
															IF bagger.bagOpenFingers.BagGrabbed THEN
																SetBagOpenState(BAG_OPEN_ASSIST_STATES.BagOpened);
															ELSIF bagger.bagOpenFingers.BagMissed THEN
																SetBagOpenState(BAG_OPEN_ASSIST_STATES.BagFailedToOpen);
															END_IF
														ELSE 
															SetBagOpenState(BAG_OPEN_ASSIST_STATES.MovingJawOutAfterGrab);
														END_IF
													  
	BAG_OPEN_ASSIST_STATES.BagFailedToOpen :			// 
														bagger.bagOpenFingers.ReleaseBag();
														bagger.CurrentBagOpenRetryCount := bagger.CurrentBagOpenRetryCount + 1;
														IF bagger.CurrentBagOpenRetryCount < bagger.bagOpenRetrySetting THEN
															SetBagOpenState(BAG_OPEN_ASSIST_STATES.MoveJawIn);
														ELSE 
															SetBagOpenState(BAG_OPEN_ASSIST_STATES.MovingJawOutAfterGrab);
															bagger.CurrentBagOpenRetryCount := 0; 
															bagger.failedToOpenBag.Trigger();
														END_IF
	
	BAG_OPEN_ASSIST_STATES.BagOpened :					//
														bagger.vacuumBagOpen.StopVacuum();
                                                    	bagger.sealFlatteners.BagIsOpen();
														bagger.CurrentBagOpenRetryCount := 0;
// 														HMIData.bagsMade.Increment();
// 														HMIData.airFilterClean.Increment();
// 														HMIData.baggerCycles.Increment();
														SetBagOpenState(BAG_OPEN_ASSIST_STATES.MovingJawOutAfterGrab);
														
                                      
    BAG_OPEN_ASSIST_STATES.MovingJawOutAfterGrab :		// 
														IF bagger.pressureBar.IsFullyOpen 
															AND (bagger.sealFlatteners.InPosition OR NOT bagger.sealFlatteners.OptionActive)
															THEN
																SetBagOpenState(BAG_OPEN_ASSIST_STATES.MovedJawOut);    
														END_IF	 
														
	
	BAG_OPEN_ASSIST_STATES.MovedJawOut :            	// 
														
														SetBagOpenState(BAG_OPEN_ASSIST_STATES.Done);

                                                             
                                                
	//BAG_OPEN_ASSIST_STATES.FeedNewBag :   				//
													
													
                                                
    //BAG_OPEN_ASSIST_STATES.Done :                    	// 
                                                            
    //BAG_OPEN_ASSIST_STATES.Fault :                    //

END_CASE