(*#-#-#-#-#-#-#-#-#-#---Declaration---#-#-#-#-#-#-#-#-#-#-#-#-#*)
FUNCTION_BLOCK FB_EZFeed EXTENDS FB_BaseComponent IMPLEMENTS IComponentStatus
VAR_INPUT
	baggerFaulted : BOOL;
	enableEZFeed : BOOL;					// Enable EZFeed conveyor (In Use)
	continuousModeEnable : BOOL; 			// 0 = indexing mode, 1 = continuous mode
	partsCountingModeEnable : BOOL;			// 0 = Flight counting only, 1 = Parts counting (requires sensor or light curtains)
	flightPresentSensor : BOOL;				// Flight present 
	partPresentSensor : BOOL;				// Part present/dropping (photoeye, light curtain, etc)
	waitingForFiller : BOOL;				// Waiting for Filler signal from bagger
	indexDwellSetting : REAL;				// Indexing dwell setting
	flightTarget : DINT;					// For Flight counting mode, target flights before starting cycle
	partsTarget : DINT;						// For Parts counting mode, target parts before starting cycle
	emptyPartsWarningSetting : DINT;		// For Parts counting mode, setting of empty flights counted before warning issued
	restartFromEmptyParts : BOOL;			// Restart EZFeed after starvation/empty parts. Usually cycle start button
END_VAR
VAR_OUTPUT
	state : EZFEED_STATES;					// State machine
	runVFD : BOOL;							// Run VFD output
	flightCount : DINT;						// Actual flight count
	partsCount : DINT;						// Actual parts count
	emptyPartsWarningCount : DINT;			// Actual empty flights count
	EZFeedDone : BOOL;						// EZFeed done - cycle bagger
	emptyPartsWarning : BOOL;				// Parts starved
END_VAR
VAR
	indexDwellTimer : TON;
	flightPresentONS : FB_ONS;
	partPresentONS : FB_ONS;
END_VAR
	
VAR_IN_OUT
END_VAR
(*#-#-#-#-#-#-#-#-#-#---Implementation---#-#-#-#-#-#-#-#-#-#-#-#-#*)
//    Function Block: EZFeedFB
//    Description: EZFeed state machine
//    Created by: Ben Hess
//    Created Date: December 3rd, 2020




// Resetting 
//IF resetONS.Q OR baggerFaulted OR NOT enable OR NOT enableEZFeed THEN
IF _reset OR baggerFaulted OR NOT enable OR NOT enableEZFeed THEN
	state := EZFEED_STATES.Idle;
	runVFD := FALSE;
	EZFeedDone := FALSE;
	flightCount := 0;
	partsCount := 0;
	emptyPartsWarningCount := 0;
END_IF

// Timer for indexing dwell
indexDwellTimer(PT := TO_TIME(indexDwellSetting * 1000), IN := state = EZFEED_STATES.IndexDwell);

flightPresentONS(CLK := flightPresentSensor);
partPresentONS(CLK := partPresentSensor);

// Parts Counting logic
IF partsCountingModeEnable AND (state = EZFEED_STATES.IndexingPartsMode OR state = EZFEED_STATES.IndexDwell) THEN
	// Count flights for empty parts watchdog timer
	IF flightPresentONS.OSR THEN
		emptyPartsWarningCount := emptyPartsWarningCount + 1;
	END_IF
	
	IF partPresentONS.OSF THEN
		emptyPartsWarningCount := 0;
		partsCount := partsCount + 1;
	END_IF
	
END_IF

emptyPartsWarning := state = EZFEED_STATES.PartsStarved;

CASE state OF
	
	EZFEED_STATES.Idle :						// When filler reports as waiting for filler, start indexing the EZFeed
												IF enableEZFeed AND waitingForFiller THEN
													IF partsCountingModeEnable THEN
														state := EZFEED_STATES.IndexingPartsMode;
													ELSE
														state := EZFEED_STATES.IndexingFlightMode;
													END_IF
													
												END_IF
	
	EZFEED_STATES.IndexingPartsMode :			// Check parts count and start bagger if count reached
												runVFD := TRUE;
												IF flightPresentONS.OSR THEN
													IF (emptyPartsWarningCount >= emptyPartsWarningSetting) AND emptyPartsWarningSetting<> 0 THEN
															runVFD := FALSE;
															state := EZFEED_STATES.PartsStarved;
													
													ELSIF partsCount >= partsTarget THEN
														partsCount := 0;
														runVFD := FALSE;
														EZFeedDone := TRUE;
														state := EZFEED_STATES.WaitForBaggerCycleComplete;
													ELSE
														// Dwell at each flight for indexing mode
														IF NOT continuousModeEnable THEN
															runVFD := FALSE;
															state := EZFEED_STATES.IndexDwell;
														END_IF
													END_IF
												END_IF
												
		
	EZFEED_STATES.IndexingFlightMode :			// Run the VFD until flight seen. Keep going until target reached in Continuous mode or stop for dwell time in indexing mode
												runVFD := TRUE;
												IF flightPresentONS.OSR THEN
													flightCount := flightCount + 1;
													// Check flight count and start bagger if count reached
													IF flightCount >= flightTarget THEN
														runVFD := FALSE;
														EZFeedDone := TRUE;
														flightCount := 0;
														state := EZFEED_STATES.WaitForBaggerCycleComplete;
													ELSE
														// Dwell at each flight for indexing mode
														IF NOT continuousModeEnable THEN
															runVFD := FALSE;
															state := EZFEED_STATES.IndexDwell;
														END_IF
													END_IF
												END_IF
												
	EZFEED_STATES.IndexDwell :					// Dwell at each flight for indexing mode
												IF indexDwellTimer.Q THEN
													IF partsCountingModeEnable THEN
														IF (emptyPartsWarningCount >= emptyPartsWarningSetting) AND emptyPartsWarningSetting<> 0 THEN
															runVFD := FALSE;
															state := EZFEED_STATES.PartsStarved;
														END_IF
														IF partsCount >= partsTarget THEN
															partsCount := 0;
															runVFD := FALSE;
															EZFeedDone := TRUE;
															state := EZFEED_STATES.WaitForBaggerCycleComplete;
														ELSE
															state := EZFEED_STATES.IndexingPartsMode;
														END_IF
													ELSE
														state := EZFEED_STATES.IndexingFlightMode;
													END_IF
												END_IF
												
	EZFEED_STATES.WaitForBaggerCycleComplete :	// Once bagger cycle is complete then resume indexing
												IF waitingForFiller THEN
													EZFeedDone := FALSE;
													IF partsCountingModeEnable THEN
														state := EZFEED_STATES.IndexingPartsMode;
													ELSE
														state := EZFEED_STATES.IndexingFlightMode;
													END_IF
												END_IF
								
	EZFEED_STATES.PartsStarved:					//
												IF restartFromEmptyParts THEN
													emptyPartsWarningCount := 0;
													IF partsCountingModeEnable THEN
														state := EZFEED_STATES.IndexingPartsMode;
													ELSE
														state := EZFEED_STATES.IndexingFlightMode;
													END_IF
												END_IF
												
									
	EZFEED_STATES.Fault :						//
												

END_CASE

// Run parent FB
SUPER^();