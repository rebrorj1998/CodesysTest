

FUNCTION_BLOCK FB_SimulatedFeedback EXTENDS FB_BaseObject
VAR_INPUT
	in : BOOL;			// Start of feedback (usually an output)
	simFeedbackFault : BOOL;	// Enable a feedback fault
	faultDelay : DINT;			// Delay for feedback fault
	minDelay : DINT;	//Minimum delay in mS
	maxDelay : DINT;	//Maximum delay in mS
END_VAR
VAR_OUTPUT
	Q : BOOL;
	fault : BOOL;
END_VAR
VAR
	inONS : FB_ONS();
	QONS : FB_ONS();
	_beginTimer : BOOL;
	randomDelay : DINT;
	delayTimer : Standard.TON;
END_VAR

//	Function Block: FB_SimulatedFeedback
//	Description: Meant to simulate a feedback based off an input with an additional option to simulate a failed feedback signal
//				 Can be used for testing or for creating "feedback" for components that lack a sensor
//
//	Usage: simPbarInFB(in := movePbarInOutput, minDelay := 100, maxDelay := 200);
// 
//	Created by: Ben Hess
//	Created Date: 3-2019

inONS(CLK := in);
QONS(CLK := Q);
IF minDelay < 0 THEN
	minDelay := 0;
END_IF
IF inONS.OSR THEN
	_logger.AddLogItem(CONCAT(_prefix,'Started'));
	// Feeback can be set as a range to simulate variations in air pressure, friction etc.
	// Choose a random delay in between min and max
	IF NOT simFeedbackFault THEN
		randomDelay := 	FN_RandomDINT(last := randomDelay,
								low := minDelay,
								high := maxDelay);
		delayTimer.PT := DINT_TO_TIME(randomDelay);	
	ELSE 
		// Use fault timer if fault sim enabled
		delayTimer.PT := DINT_TO_TIME(faultDelay);
	END_IF
END_IF

IF QONS.OSR AND NOT simFeedbackFault THEN
	_logger.AddLogItem(CONCAT(_prefix,'Done'));
END_IF
				
delayTimer(IN := in);

IF NOT simFeedbackFault THEN
	Q := delayTimer.Q;
	fault := FALSE;
ELSE 
	Q := FALSE;
	fault := delayTimer.Q;
END_IF


FUNCTION_BLOCK FB_SimulatedFeedback EXTENDS FB_BaseObject
VAR_INPUT
	in : BOOL;			// Start of feedback (usually an output)
	simFeedbackFault : BOOL;	// Enable a feedback fault
	faultDelay : DINT;			// Delay for feedback fault
	minDelay : DINT;	//Minimum delay in mS
	maxDelay : DINT;	//Maximum delay in mS
END_VAR
VAR_OUTPUT
	Q : BOOL;
	fault : BOOL;
END_VAR
VAR
	inONS : FB_ONS();
	QONS : FB_ONS();
	_beginTimer : BOOL;
	randomDelay : DINT;
	delayTimer : Standard.TON;
END_VAR

//	Function Block: FB_SimulatedFeedback
//	Description: Meant to simulate a feedback based off an input with an additional option to simulate a failed feedback signal
//				 Can be used for testing or for creating "feedback" for components that lack a sensor
//
//	Usage: simPbarInFB(in := movePbarInOutput, minDelay := 100, maxDelay := 200);
// 
//	Created by: Ben Hess
//	Created Date: 3-2019

inONS(CLK := in);
QONS(CLK := Q);
IF minDelay < 0 THEN
	minDelay := 0;
END_IF
IF inONS.OSR THEN
	_logger.AddLogItem(CONCAT(_prefix,'Started'));
	// Feeback can be set as a range to simulate variations in air pressure, friction etc.
	// Choose a random delay in between min and max
	IF NOT simFeedbackFault THEN
		randomDelay := 	FN_RandomDINT(last := randomDelay,
								low := minDelay,
								high := maxDelay);
		delayTimer.PT := DINT_TO_TIME(randomDelay);	
	ELSE 
		// Use fault timer if fault sim enabled
		delayTimer.PT := DINT_TO_TIME(faultDelay);
	END_IF
END_IF

IF QONS.OSR AND NOT simFeedbackFault THEN
	_logger.AddLogItem(CONCAT(_prefix,'Done'));
END_IF
				
delayTimer(IN := in);

IF NOT simFeedbackFault THEN
	Q := delayTimer.Q;
	fault := FALSE;
ELSE 
	Q := FALSE;
	fault := delayTimer.Q;
END_IF
